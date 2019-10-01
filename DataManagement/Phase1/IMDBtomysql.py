import pymysql
import pandas as pd


def connectdb():
    print('connecting mysql server')
    db =pymysql.connect("localhost","root","740832Qjx!","IMDB")
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


def main():
    #db = connectdb()
    data=pd.read_csv('titlebasics.tsv', sep='\t',header=0)

    for i in range(10):
        print("insert into title"+" values('"+data['tconst'][i]+"','"+data['titleType'][i]+"','"
              + data['primaryTitle'][i]+"','"+data['originalTitle'][i]+"',"
                + checkBool(data['isAdult'][i])+","+str(data['startYear'][i])+","+checkN(data['endYear'][i])+", 0,0);")

    #data.close()

    rating=pd.read_csv('ratings.tsv', sep='\t',header=0)

    for i in range(10):
        print("update title set average_rating = "+ str(rating['averageRating'][i])+", num_votes= "+str(rating['numVotes'][i])+" where tconst ='"+rating['tconst'][i]+"';")

    #rating.close()

    #db.close()

if __name__ == '__main__':
    main()
