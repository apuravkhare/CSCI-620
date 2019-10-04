import pymysql
import pandas as pd
import json


def connectdb():
    print('connecting mysql server')
    db =pymysql.connect("localhost","root","password","imdb_staging")
    print('connecting finish')
    return db

def operationdb(sql_insert,db):
    cursor=db.cursor()
    try:
        cursor.execute(sql_insert)
        db.commit()
    except:
        db.rollback()

def record(sql_operation,filename):
    recording=open(filename,'a')
    recording.write("\n"+sql_operation)
    recording.close()

def checkN(string):
    if string==r"\N":
        return "null"
    else:
        return int(string)

def checkBool(string):
    if string == 0:
        return 'false'
    else:
        return 'true'

def createSql(tableName, columns):
    return "insert into `" + tableName + "` (" + ",".join(columns) + ") values (" + ",".join( ["%s"]*len(columns) ) + ")"
'''
def createSql(tableName, columns, rows):
    return "insert into `" + tableName + "` (" + ",".join(columns) + ") values (" + ",".join(rows)
'''

def bulkInsert(qualifiedFilePath, tableName):
    connection = connectdb()
    fileData = pd.read_csv(qualifiedFilePath, sep='\t', header=0)
    try:
        with connection.cursor() as cursor:
            sql = createSql(tableName, fileData.columns)
            print("Importing table: " + tableName + "; columns: " + ",".join(fileData.columns))
            for index in range(len(fileData)):
                rowValues = [ str(fileData[column][index]).replace("'", "`'") if fileData[column][index] != "\\N" else "NULL" for column in fileData.columns ]
                
                if index > 0 and index % 100000 == 0:
                    print(str(index + 1) +" rows completed.")
                
                cursor.execute(sql, rowValues)
            connection.commit()
    finally:
        connection.close()
        #fileData.close()

    print(tableName + " completed.")

def main():
    #db = connectdb()
    with open('table_map.json') as jsonFile:
        tableMap = json.load(jsonFile)
        filePath = tableMap["filePath"]
        for key in tableMap["files"].keys():
            bulkInsert(filePath + key, tableMap["files"][key])
    '''
    data=pd.read_csv('titlebasics.tsv', sep='\t', header=1)
    
    for i in range(10):
        print("insert into title"+" values('"+data['tconst'][i]+"','"+data['titleType'][i]+"','"
              + data['primaryTitle'][i]+"','"+data['originalTitle'][i]+"',"
                + checkBool(data['isAdult'][i])+","+str(data['startYear'][i])+","+checkN(data['endYear'][i])+", 0,0);")

    #data.close()

    rating=pd.read_csv('ratings.tsv', sep='\t',header=0)

    for i in range(10):
        print("update title set average_rating = "+ str(rating['averageRating'][i])+", num_votes= "+str(rating['numVotes'][i])+" where tconst ='"+rating['tconst'][i]+"';")
    '''
    #rating.close()

    #db.close()

if __name__ == '__main__':
    main()
