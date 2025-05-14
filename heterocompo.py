import pandas as pd

file= r"C:\Users\stude\Downloads\composites.xlsx"
dF= pd.read_excel(file, sheet_name="RendusNEG")


for index,row in dF.iterrows():
    x = str(row["OMIM"]).split(";") if pd.notna(row["OMIM"]) else []
    y = str(row["hpo"]).split("|") if pd.notna(row["hpo"]) else []
    print(x,y)
    similarity = list(set(x) & set(y))
    dF.at[index, "similarity"] = similarity if similarity else "rien"
    
dF.to_excel(r"C:\Users\stude\Downloads\composites_updated.xlsx",index=False)




