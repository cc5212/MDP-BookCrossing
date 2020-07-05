import pandas as pd
import csv

def __main__():
    csv_name = input("Archivo csv: ")
    data = pd.read_csv(csv_name, sep=";")#, encoding="ASCII")
    data.to_csv('BX-Books.tsv',sep='\t', index=False, header=False, quoting=csv.QUOTE_NONE, escapechar='\\')