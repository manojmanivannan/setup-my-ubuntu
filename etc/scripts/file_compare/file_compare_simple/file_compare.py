#!/usr/bin/python3

"""
This python script is used to compare the generated feed in the form of csv from the EMC/EDC and validates 
with the artifact csv.
The script takes 5 arguments

1.  File path of the generated CSV
2.  File path of the artifact to compare
#3.  File path of the validation_config.ini
4.  Project name (eg.eva-ecc-emc,dcloud-end2end)
5.  Name of the test suite (eg.thirdparty-feed-validation,end-2-end)
6.  Run Index
7.  Repetition
8.  File path of the ATF main log file
----------------------------
Date    : 18-October-2019
Author  : Manoj Manivannan
----------------------------
"""
import sys, ast
import os, glob
from datetime import datetime
import pandas as pd
import numpy as np
import configparser
import copy
from posix import lseek
from collections import Counter


OKGREEN = '\033[32m'
WARNING = '\033[33m'
FAIL    = '\033[31m'
ENDC    = '\033[0m'


def printinfo(msg):
    output = "[{}] INFO: {}".format(datetime.now().strftime("%H:%M:%S"),msg)
    #f = open(main_log_file,"a+");f.write(output+"\n");f.close
    print (OKGREEN+output+ENDC, file=sys.stdout)

def printerr(msg):
    output = "[{}] ERROR: {}".format(datetime.now().strftime("%H:%M:%S"),msg)
    #f = open(main_log_file,"a+");f.write(output+"\n");f.close
    print (FAIL+output+ENDC, file=sys.stderr)
    #sys.exit(1)

def printwarn(msg, display_error=False):
    output = "[{}] ALERT: {}".format(datetime.now().strftime("%H:%M:%S"),msg)
    #f = open(main_log_file,"a+");f.write(output+"\n");f.close
    WARN_COLOR = FAIL if display_error else WARNING
    print (WARN_COLOR+output+ENDC, file=sys.stdout)

def table_printer(list_1,list_2, list_1_heading, list_2_heading):
    """This function prints missing entires given two lists in table form
        
        list_1 = ['a', 'b', 'c', 'd', 'e', 'f']
        list_2 = ['b', 'c', 'f', 'z']

        list_1       list_2    
        ----------------------
        a            --MISSING--   
        b            b         
        c            c         
        d            --MISSING--   
        e            --MISSING--   
        f            f         
        --MISSING--  z  
    """
    from collections import OrderedDict
    
    mapping = OrderedDict()
    for x in list_1:
        mapping[x] = x if x in list_2 else '--MISSING--'
    
    for x in list_2:
        mapping[x] = x if x in list_1 else '--MISSING--'
    
    table_format = '{:<50} {:<50}'
    print(table_format.format(list_1_heading, list_2_heading))
    print('-' * 100)
    
    for k in mapping:
        if k in list_1:
            print(table_format.format(k, mapping[k]))
        else:
            print(table_format.format(mapping[k], k))
            
def get_included_columns(path):
    
    if not os.path.isfile(path):
        printerr("Config file for included columns does not exist: {}".format(path))

    printinfo("Using config file from: {}".format(path))
    config_file = configparser.ConfigParser()
    try:
        config_file.read(path)
    except configparser.MissingSectionHeaderError:
        printerr("{} is not a valid configuration file, is it validation_config.ini ?".format(path))
    
    try:
        included_columns = list(filter(None,(config_file['Fields_tobe_Included']['Included_Columns_analytics']).split(',')))
        summation_columns = list(filter(None,(config_file['Fields_tobe_Included']['Summation_Columns_analytics']).split(',')))
        variance_columns = ast.literal_eval(config_file['Fields_tobe_Included']['Variance_Columns_analytics'])
        absolute_columns = ast.literal_eval(config_file['Fields_tobe_Included']['Absolute_Columns_analytics'])

    except KeyError as e:
        printerr("'{}'' definition does not exist in {}".format(e.args[0],path))

    try:
        scale_factor = ast.literal_eval(config_file['Fields_tobe_Included']['scale_factor'])
    except:
        printinfo("ScaleFactor not defined, assuming scale_factor = 1")
        scale_factor = 1
        
    included_columns = [x.strip() for x in included_columns]
    summation_columns = [x.strip() for x in summation_columns]
    #variance_columns = [x.strip() for x in variance_columns]
    #absolute_columns = [x.strip() for x in absolute_columns]

    return included_columns, variance_columns, absolute_columns, summation_columns, scale_factor

def select_columns_of_interest(df1,df2,intr_columns):
    """This function gets only the columns mentioned
    in the validation_config.ini file in both the generated and 
    artifact file. does not perform any validation
    """
    # Perform validation to check if both the generated and artifact contain the same records.
    # cases when new record added to product, but not validated/updated in artifact will 
    # cause test case to fail
    if not len(df1.columns) == len(df2.columns):
        
        print("Num of columns in expected feed: {}: {}\n{}".format(len(df1.columns), sorted(df1.columns), df1.columns.str.match('Unnamed')))
        print("Num of columns in generated feed: {}: {}".format(len(df2.columns), sorted(df2.columns)))
        
        columns_not_present = list(set(df1.columns).symmetric_difference(set(df2.columns)))
        if len(df1.columns) > len(df2.columns):
            columns_not_present_where = 'artifact'
            columns_present_where     = 'generated'
            columns_not_present_msg   = 'Consider validating those column(s) or add header alone in artifact to ignore'
        else:
            columns_not_present_where = 'generated'
            columns_present_where     = 'artifact'
            columns_not_present_msg   = 'Implementation required in EMC or typo error'

        # columns_not_present_where = 'artifact' if len(df1.columns) > len(df2.columns) else 'generated'
        # columns_present_where = 'artifact' if len(df1.columns) < len(df2.columns) else 'generated'
        printerr("Column(s) {} in {} csv does not exist in {} csv. {}".format(columns_not_present,columns_present_where,columns_not_present_where,columns_not_present_msg))

    try:
        df1_to_return = df1.drop(df1.columns.difference(intr_columns),axis=1)   # drop the columns that we dont need
        df2_to_return = df2.drop(df2.columns.difference(intr_columns),axis=1)   # drop the columns that we dont need
        # Sort the order of columns before return so both frames are identical
        return df1_to_return.reindex(sorted(df1_to_return.columns), axis=1), df2_to_return.reindex(sorted(df2_to_return.columns), axis=1)
     
    except Exception as e:
        
        printerr("Dropping columns failed: {}".format(e))

def read_csv(path):
    """
    This function reads the csv into pandas dataframe
    and fills NaN with 0

    Return: Pandas dataframe
    """
    if not os.path.isfile(path):
        printerr("CSV file {} does not exist".format(path))

    try:
        df = pd.read_csv(path, dtype={0: str}, na_values='\\N').fillna(0) # filling Nan values with 0's, since using string will hinder comparison later in functions like tolerance comparison
        
        # remove Unnamed columns generated by pandas library when there is a trailing comma:
        if df.columns[-1].startswith("Unnamed"):
            df = df.drop(df.columns[-1], axis=1)

    except Exception as e:
        printerr("Unable to read csv file {} into pandas with exception: {}".format(path, e))

    return df


def check_frame_structure(gen_df, art_df, relative_variance, absolute_variance,summation):
    
    """This function checks if the two dataframes are equal in columns, rows
    and the column length.
    It also checks if the columns in the frames are identical to the ones present in
    the validation_config.ini file
    """   
    global type_of_comparison

    if not (len(gen_df) == len(art_df)):
        printerr("Generated CSV does not have the same number of rows as the artifact")
   
    if relative_variance:
        # choose columns with variances
        variance_col_keys = copy.deepcopy(list(variance_columns.keys()))
        validation_col_list = sorted(variance_col_keys)
        type_of_comparison = 'Variance_Columns_analytics'
    elif absolute_variance:
         absolute_col_keys = copy.deepcopy(list(absolute_columns.keys()))
         validation_col_list = sorted(absolute_col_keys)
         type_of_comparison = 'Absolute_Columns_analytics'
    elif summation:
         absolute_col_keys = copy.deepcopy(summation_columns)
         validation_col_list = sorted(summation_columns)
         type_of_comparison = 'Summation_Columns_analytics'
    else:
        # choose columns with absolute values
        included_col_list = copy.deepcopy(included_columns)
        validation_col_list = sorted(included_col_list)
        type_of_comparison = 'Included_Columns_analytics'

    gen_df_col_list = sorted(list(copy.deepcopy(gen_df.columns))) # create copy and sort it to avoid changing the actual list
    
    # Finds the difference between the columns in the generated (ignoring artifact df since it was already validated) df 
    # versus the ones to be compared in validation
    #print("Num of columns in expected feed: {}".format(len(art_df.columns)))
    #print("Num of columns in generated feed: {}".format(len(gen_df.columns)))
    
    if len(set(validation_col_list).symmetric_difference(set(gen_df_col_list))) >= 1:
#         table_printer(gen_df_col_list, validation_col_list, list_1_heading='Generated', list_2_heading='Variance columns')
        printerr("Column(s) {} in validation_config.ini ({}) does not exist in artifact and generated csv".format(set(validation_col_list).symmetric_difference(set(gen_df_col_list)), type_of_comparison))
    
    
    return True

def print_verbose_failure_msg(df):
    df.dropna(axis=1,how="all",inplace=True)
    for column in df.columns:
        for idx,row in df[column].iteritems():
            if pd.notnull(row):
                if type_of_comparison == 'Variance_Columns_analytics':

                    column_name = column.split('_rtol=')[0]                     # Name of the column
                    scale_factor= "(ScaleFactor="+column.split('_SF=')[1]+")"   # Scale factor(SF) is used when the actual value is SF times the expected. Default is 1
                    symbol='\u00B1'                                             # plus or minus
                    tolerance = str(float(column.split('_rtol=')[1].split('_SF')[0])*100)+"%" # Tolerance value specified in the validation_config.ini. But extracted from the column name here
                    expected = row.split(' | ')[0]                              # Expected value
                    actual = row.split(' | ')[1]                                # Actual value
                    row_id = str(idx)                                           # Row num written to csv
                
                elif type_of_comparison == 'Absolute_Columns_analytics':

                    column_name = column.split('_atol=')[0]
                    scale_factor= "(ScaleFactor="+column.split('_SF=')[1]+")"
                    symbol='\u003C'          # less than
                    tolerance = str(float(column.split('_atol=')[1].split('_SF')[0]))
                    expected = 'any value'
                    actual = row.split(' | ')[1]
                    row_id = str(idx)

                elif type_of_comparison == 'Summation_Columns_analytics':

                    column_name = column
                    scale_factor=''
                    symbol=''
                    tolerance=''
                    expected = row.split(' | ')[0]
                    actual = row.split(' | ')[1]
                    row_id = str(idx)

                elif type_of_comparison == 'Included_Columns_analytics':

                    column_name = column
                    scale_factor=''
                    symbol=''
                    tolerance=''
                    expected = row.split(' | ')[0]
                    actual = row.split(' | ')[1]
                    row_id = str(idx)

                expected_str = expected + symbol + tolerance
                printwarn("Column '{}'{} expected [{}], but found [{}] at row {}".format(column_name,scale_factor,expected_str,actual,row_id), display_error=True)
                #import traceback
                #traceback.print_stack()


def write_csv_failure(df):

    csv_file_name = os.path.splitext(os.path.basename(generated_file))[0]
    csv_artifact_path = automation_temp_path+'/'+csv_file_name+'_FAIL_RUNINDEX_'+str(run_index)+'.csv'
    #     df.columns = pd.MultiIndex.from_product([df.columns, ['A | G']])
    df.dropna(axis=1,how="all").to_csv(csv_artifact_path,na_rep='PASSED',index=False)
    printwarn("Artifact saved to {}".format(csv_artifact_path))
    print_verbose_failure_msg(df)
    printerr("Artifact comparison Failed")
    
def mask_frame(difference_df, masker_df):
    """
    This function masks all values where the values of the boolean
    dataframe is True
    """
    masker_df['RowNo'] = [str(i+1) for i in range(len(masker_df))] # Prepare mask dataframe for masking with result
    masker_df.set_index('RowNo',inplace=True)
    masked_df = difference_df.mask(masker_df)
    return masked_df

def compare_dataframes(gen_df,art_df,relative_variance=False,absolute_variance=False,summation=False,scale_factor=1):
    """
    This function compares values of each row between the two dataframes
    and logs the difference if it finds any
    gen_df is the dataframe with generated csv feed values
    art_df is the dataframe with artifact csv values

    Return: Dataframe of difference between generated and artifact, or None if no difference found
    """
    def diff_equality(x):
        return np.nan if x[0]*scale_factor == x[1] else '{} | {}'.format(*x)

    
    def df_identify_difference(df1,df2):
        """
        This function merges the two dataframes,
        but fills the values of both the frames 
        separated by '|' if they are different.
        """
        # df1 is the generated csv
        # df2 is the artifact
        
        df1['RowNo'] = [str(i+1) for i in range(len(df1))]
        df2['RowNo'] = [str(i+1) for i in range(len(df2))]
        df = pd.concat([df1,df2])
        df_concat = pd.concat(
            [df1.set_index('RowNo'), df2.set_index('RowNo')],
            axis='columns', 
            keys=['Generated Feed', 'Artifact'],
            join='outer',
            sort=False
            )
        df_all = df_concat.swaplevel(axis=1)[df1.columns[:-1]]
        return df_all.groupby(level=0, axis=1).apply(lambda frame: frame.apply(diff_equality, axis=1))

    if relative_variance:
        # Here we check if columns are complying within a range.
#         printinfo("Checking for match within tolerance")
        mask_dict = {}
        for col in list(variance_columns.keys()):
            lower_limit = (gen_df[col]-(gen_df[col]*variance_columns[col]))*scale_factor
            upper_limit = (gen_df[col]+(gen_df[col]*variance_columns[col]))*scale_factor
            mask_dict[col] = (art_df[col].between(lower_limit, upper_limit, inclusive=True))

        masker = pd.DataFrame(mask_dict)   # Masked frame where True means they are within tolerance, False otherwise

        if masker.all().all():
            # True only if all values in the dataframe are True
            printinfo("Generated CSV and artifact matched within relative tolerances for column(s) {}".format(list(variance_columns.keys())))
            printinfo("{} column(s) passed".format(len(list(variance_columns.keys()))))
            return None
        else:
            # there have been some false (outside tolerance)
            result = df_identify_difference(gen_df,art_df)
            masked_df = mask_frame(result, masker)
            masked_df = masked_df[masker.columns.values[~(masker.all())]]
            printwarn("Generated CSV and artifact did not match within relative tolerances for column(s) {}. Test failing".format(masked_df.columns.values))
            masked_df.rename(columns={col: col+'_rtol='+str(tol)+'_SF='+str(scale_factor) for col,tol in variance_columns.items()},inplace=True)
            return masked_df

    elif absolute_variance:
        # Here we check if columns are complying within a range.
#         printinfo("Checking for match within tolerance")
        mask_dict = {}

        for col in list(absolute_columns.keys()):
            mask_dict[col] = (art_df[col].between(0, absolute_columns[col], inclusive=True))
       
        masker = pd.DataFrame(mask_dict)   # Masked frame where True means they are within tolerance, False otherwise

        if masker.all().all():
            # True only if all values in the dataframe are True
            printinfo("Generated CSV and artifact matched within absolute tolerances for column(s) {}".format(list(absolute_columns.keys())))
            printinfo("{} column(s) passed".format(len(list(absolute_columns.keys()))))
            return None
        else:
            # there have been some false (outside tolerance)
            result = df_identify_difference(gen_df,art_df)
            masked_df = mask_frame(result, masker)
            masked_df = masked_df[masker.columns.values[~(masker.all())]]
            printwarn("Generated CSV and artifact did not match within absolute tolerances for column(s) {}. Test failing".format(masked_df.columns.values))
            masked_df.rename(columns={col: col+'_atol='+str(tol)+'_SF='+str(scale_factor) for col,tol in absolute_columns.items()},inplace=True)
            return masked_df
    
    elif summation:
        # printinfo("checking for summation of columns match")
        # if there are difference, we get an array with index of location where values are different,
        # and if the size is 0, there was no difference
        gen_df = (pd.DataFrame(gen_df.sum()).transpose())
        art_df = (pd.DataFrame(art_df.sum()).transpose())
        masker = (gen_df != art_df)

        if np.where(masker)[0].size == 0: 
            printinfo("Generated CSV and artifact exactly matched for summation of column(s) {}".format(summation_columns))
            printinfo("{} column(s) passed".format(len(summation_columns)))
            return None
        else:
            result = df_identify_difference(gen_df,art_df)
            masked_df = mask_frame(result, masker)
            printwarn("Generated CSV and artifact did not match for summation {}. Test failing".format(result.dropna(axis=1,how="all",inplace=False).columns.to_list()))
            return result

    else:
        # printinfo("checking for absolute match")
        # if there are difference, we get an array with index of location where values are different,
        # and if the size is 0, there was no difference
        #print(gen_df.dtypes)
        #print(art_df.dtypes)
        masker = (gen_df != art_df)

        if np.where(masker)[0].size == 0: 
            printinfo("Generated CSV and artifact exactly matched for column(s) {}".format(included_columns))
            printinfo("{} column(s) passed".format(len(included_columns)))
            return None
        else:
            result = df_identify_difference(gen_df,art_df)
            masked_df = mask_frame(result, masker)
            printwarn("Generated CSV and artifact did not match {}. Test failing".format(result.dropna(axis=1,how="all",inplace=False).columns.to_list()))
            return result

def start_compare(df1,df2,relative_variance=False,absolute_variance=False,summation=False,scale_factor=1):

    if relative_variance:
        if not bool(variance_columns):
            printinfo("Nothing to compare for column(s) with relative variance")
            return
        printinfo("Comparing column(s) with relative variance")
        generated_df, artifact_df = select_columns_of_interest(df1, df2, list(variance_columns.keys())) # selecting columns of interest

    elif absolute_variance:    
        if not bool (absolute_columns):
            printinfo("Nothing to compare for column(s) with absolute variance")
            return
        printinfo("Comparing column(s) with absolute variance")
        generated_df, artifact_df = select_columns_of_interest(df1, df2, list(absolute_columns.keys())) # selecting columns of interest

    elif summation:
        if not bool (summation_columns):
            printinfo("Nothing to compare for column(s) with summation check")
            return
        printinfo("Comparing column(s) with summation check")
        generated_df, artifact_df = select_columns_of_interest(df1, df2, list(summation_columns)) # selecting columns of interest

    else:
        if not bool(included_columns):
            printinfo("Nothing to compare for column(s) with exact values")
            return
        printinfo("Comparing column(s) with exact values")
        generated_df, artifact_df = select_columns_of_interest(df1, df2, included_columns)
        
    row_column_check = check_frame_structure(generated_df, artifact_df, relative_variance=relative_variance, absolute_variance=absolute_variance, summation=summation)

    if row_column_check:

        result = compare_dataframes(artifact_df,generated_df,relative_variance=relative_variance,absolute_variance=absolute_variance,summation=summation,scale_factor=scale_factor)
    
        if result is not None:
            write_csv_failure(result)

    else:
        printerr("column(s) and/or row(s) of {} do not match with artifact {}".format(generated_file,expected_feed))


#
# Francesco's functions: a simplified non-pandas approach to the problem :-)
#

def read_csv_as_dict(path, sort_column_rule):
    """
    This function reads the csv into pandas dataframe
    and fills NaN with 0

    Return: dictionary; example format of returned dict:
        {0: {'col1': 1, 'col2': 0.5}, 1: {'col1': 2, 'col2': 0.75}}
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^
         first row
    """
    if not os.path.isfile(path):
        printerr("CSV file {} does not exist".format(path))

    ret_dict = {}
    with open(path) as fp:
        line = fp.readline().strip()
        cnt = 0
        while line:
            if cnt == 0:
                if line.endswith(','):
                    line = line[:-1]
                col_names_list = line.strip().split(',')
            else:
                ret_dict[cnt-1] = dict(zip(col_names_list, line.strip().split(',')))
            line = fp.readline().strip()
            cnt += 1

    printinfo('Found {} rows in CSV file {}'.format(len(ret_dict.keys()), path))
    # print(ret_dict)
    if bool(sort_column_rule):
        df = pd.DataFrame.from_dict(ret_dict,orient='index').sort_values(by=list(sort_column_rule.keys()), ascending=[True if sort_column_rule[key] == 'asc' else False for key in sort_column_rule ]).reset_index(drop=True)
    else:
        df = pd.DataFrame.from_dict(ret_dict,orient='index')
    df.columns = df.columns.str.replace('"',"")
    return df

def read_expected_from_ini_format(path):
    """
    Reads the given INI file and creates a Pandas dataframe from it
    """
    
    if not os.path.isfile(path):
        printerr("INI file {} does not exist".format(path))
    
    ret_dict = {}
    ret_excluded_column_list = []
    sort_column_rule = {}
    sort_column_values = {}
    with open(path) as fp:
        line = fp.readline().strip()
        cnt = 1
        while line:
            #print("Line {}: {}".format(cnt, line.strip()))
            if line[0]=='#': # skip comments
                if 'sort-' in line: 
                    keyval = line[11:].split('=')
                    sort_column_rule[keyval[0]] = line[:10].split('-')[1]
                    sort_column_values[keyval[0]] = keyval[1].split(',')
                else:
                    keyval = line[1:].split('=')
                if len(keyval)>=2:
                    # consider this line commented out as a column to be ignored
                    ret_excluded_column_list.append(keyval[0])
            elif '=' in line:
                if 'sort-' in line: 
                    keyval = line[10:].split('=')
                    sort_column_rule[keyval[0]] = line[:9].split('-')[1]
                    sort_column_values[keyval[0]] = keyval[1].split(',')
                else:
                    keyval = line.split('=')
                if len(keyval)<2:
                    printerr("Invalid syntax in INI file {} at line {}: {}".format(path, cnt, line))
                    sys.exit(2)
                elif len(keyval)==2:
                    ret_dict[keyval[0]]=keyval[1].split(',')
                else:
                    # more than 2 tokens; that means that the symbol "=" is appearing INSIDE the values... that's ok though:
                    colname = keyval[0]
                    values = '='.join(keyval[1:])
                    ret_dict[colname]=values.split(',')
            else:
                printerr("Invalid syntax in INI file {} at line {}: {}".format(path, cnt, line))
            
            line = fp.readline().strip()
            cnt += 1

    # Temporarily add the sort column to the main dict 
    if bool(sort_column_rule):
        ret_dict = {**ret_dict, ** sort_column_values}
        # print(df)
        try:
            df = pd.DataFrame.from_dict(ret_dict).sort_values(by=list(sort_column_rule.keys()), ascending=[True if sort_column_rule[key] == 'asc' else False for key in sort_column_rule ]).reset_index(drop=True)
            # Remove the sort column from the frame
            #df.drop(list(sort_column_rule.keys()), axis=1, inplace=True)
        except ValueError:
            printerr("One of More fields do not have the same number of records in {} file".format(path))
            printerr([key for key,d_array in ret_dict.items() if len(d_array) in [s[0] for s in Counter([ len(value) for key,value in ret_dict.items()]).most_common()[1:]]])
            return None, None, None
    else:
        # print(ret_dict)
        try:
            df = pd.DataFrame.from_dict(ret_dict)
        except ValueError:
            printerr("One or more fields do not have the same number of records in {} file".format(path))
            printerr([key for key,d_array in ret_dict.items() if len(d_array) in [s[0] for s in Counter([ len(value) for key,value in ret_dict.items()]).most_common()[1:]]]) # print those fields which have values different from the rest of the fields
            return None, None, None

    return df, ret_excluded_column_list, sort_column_rule

def write_generated_feed_as_ini(outdict, outpath, excluded_col_list):
    """
    Writes the generated feed  in the same format used by the expected feed artifact to simplify
    comparison and / or update of the expected artifact
    """
        
    printinfo('Writing the good expected INI as {}'.format(outpath))
    # print(outdict)
    with open(outpath, 'w') as fp:
        row0 = outdict[0]
        for colname in sorted(row0.keys()):
            #print(colname)
            values_all_rows = [str(row_dict[colname]) for row_dict in outdict.values()]
            if colname in excluded_col_list:
                colname="#"+colname
            fp.write('{}={}\n'.format(colname, ','.join(values_all_rows)))


def compare_feeds(dict_gen, dict_exp, excluded_column_list):
    """
    Compares 2 dictionaries containing GENERATED and EXPECTED feeds
    Example format of both dicts:
        {0: {'col1': 1, 'col2': 0.5}, 1: {'col1': 2, 'col2': 0.75}}
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^
         first row
    """
    
    if len(dict_gen)!=len(dict_exp):
        printerr("Different num of rows between generated feed ({}) and expected feed ({})".format(len(dict_gen),len(dict_exp)))
        return False
    
    printinfo('During comparison the following columns will be excluded as they were commented out in expected feed INI: {}'.format(','.join(excluded_column_list)))
    
    nmismatch = 0
    for row_idx in dict_gen:
        row_gen_dict = dict_gen[row_idx]
        row_exp_dict = dict_exp[row_idx]
        
        #print("Line {} has generated_dict={}, expected_dict={}".format(row_idx, row_gen_dict, row_exp_dict))
        for key,value_exp in row_exp_dict.items():
            if key not in row_gen_dict:
                printwarn("Row {}: column [{}] in expected feed is missing from generated feed!".format(row_idx, key))
                nmismatch+=1
            else:
                value_gen = str(row_gen_dict[key])
                value_exp = str(row_exp_dict[key])
                if value_gen!=value_exp:
                    printwarn("Row {}: column [{}] does not match: expected=[{}] actual=[{}]".format(row_idx, key, value_exp, value_gen))
                    nmismatch+=1
        
        for key,value_exp in row_gen_dict.items():
            if key not in row_exp_dict and key not in excluded_column_list:
                printwarn("Row {}: column [{}] in generated feed is new compared to expected feed!".format(row_idx, key))
                nmismatch+=1

    if nmismatch>0:
        printerr('Found a total of {} mismatching fields'.format(nmismatch))
        return False

    printinfo("Feeds are matching!")
    return True



#
# MAIN
#

if __name__ == '__main__':

    # parse command line argument
    # !!!FIXME: use argparse instead!!!
    generated_file  =   sys.argv[1]
    expected_feed   =   sys.argv[2]
    # config_file_path=   sys.argv[3]
    #main_log_file   =   sys.argv[8]
    
    automation_temp_path=os.path.dirname(generated_file)
    if os.path.isfile(expected_feed):
        printinfo("Expected feed: {}".format(expected_feed))
    else:
        printerr("Could not find the expected feed: {}".format(expected_feed))

    if os.path.isfile(generated_file):
        printinfo("Generated feed: {}".format(generated_file))
    else:
        printerr("Could not find the generated feed: {}".format(generated_file))

    # Loads the config file from where Column(s) to include for comparison are set
    # included_Column(s) is a list of column names with exact values to be checked
    # variance_Column(s) is a dictinonary with column names and their corresponding variance value
    # included_columns, variance_columns, absolute_columns, summation_columns, scale_factor = get_included_columns(path=config_file_path)
    
    ## FIXME change logic to check if any column name is repeated in other list
    #common_columns_variance = list(set(included_columns).intersection(variance_columns.keys()))
    #common_columns_absolute = list(set(included_columns).intersection(absolute_columns.keys()))
    #common_columns_abs_var  = list(set(variance_columns.keys()).intersection(absolute_columns.keys()))
    #
    #if bool(common_columns_variance):
    #    printerr("One or more columns found in both 'Absolute_Columns_analytics' and 'Variance_Columns_analytics', Check validation_config.ini for {}".format(common_columns_variance))
    #
    #if bool(common_columns_absolute):
    #    printerr("One or more columns found in both 'Absolute_Columns_analytics' and 'Absolute_Columns_analytics', Check validation_config.ini for {}".format(common_columns_absolute))
    #
    #if bool(common_columns_abs_var):
    #    printwarn("One or more columns found in both 'Variance_Columns_analytics' and 'Absolute_Columns_analytics', Please fix it. Check validation_config.ini for {}".format(common_columns_abs_var), display_error=True)

    # Read the csv and perform comparison
    
    dict_expected, excluded_column_list, sort_column_rule = read_expected_from_ini_format(expected_feed)

    if dict_expected is None:
        sys.exit(2)

    dict_generated = read_csv_as_dict(generated_file, sort_column_rule)
    
    # FIXME: for Manoj - get this function back to work if needed
    # start_compare(gen_file, art_file, relative_variance=False,  absolute_variance=False,    scale_factor=scale_factor)
    # start_compare(dict_generated, dict_expected, relative_variance=True,   absolute_variance=False,    scale_factor=scale_factor)
    #start_compare(gen_file, art_file, relative_variance=False,  absolute_variance=False,    scale_factor=scale_factor)
    #start_compare(gen_file, art_file, relative_variance=True,   absolute_variance=False,    scale_factor=scale_factor)
    #start_compare(gen_file, art_file, relative_variance=False,  absolute_variance=True,     scale_factor=scale_factor)
    #start_compare(gen_file, art_file, relative_variance=False,  absolute_variance=False,    summation=True,     scale_factor=scale_factor)
    if not compare_feeds(dict_generated.to_dict('index'), dict_expected.to_dict('index'), excluded_column_list):
        write_generated_feed_as_ini(dict_generated.to_dict('index'), expected_feed + '.tmp', excluded_column_list)
        sys.exit(2)
        
    sys.exit(0)
