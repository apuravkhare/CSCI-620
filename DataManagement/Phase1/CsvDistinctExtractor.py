import pandas as pd
import json
import re

def extractValues(qualifiedFilePath, column):
    distinct = set()
    fileData = pd.read_csv(qualifiedFilePath, sep='\t', header=0)
    for index in range(len(fileData)):
        rowValue: str = fileData[column][index]
        match = re.match("^\\[(.*)\\]$", str(rowValue))
        if match != None:
            rowValue = match.group(1)
        
        distinct.update(str(rowValue).split(','))
    
    with open(column + '.txt', 'w', encoding="utf-8") as file:
        file.write(",".join( [ "('" + str(v).replace("'", "''") + "')" for v in distinct ] ))

    print("processed " + qualifiedFilePath + " : " + column)
                
def main():
    with open('distinct_file_config.json') as jsonFile:
        distinctFileConfig = json.load(jsonFile)
        filePath = distinctFileConfig["filePath"]
        for key in distinctFileConfig["files"].keys():
            for column in distinctFileConfig["files"][key]:
                print("processing " + key + " : " + column)
                extractValues(filePath + key, column)

if __name__ == "__main__":
    main()