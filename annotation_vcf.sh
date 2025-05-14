#lancer mon script
#from google.colab import files
#fichier = files.upload()
#!bash mon_script.sh "VCF_LIGHT.vcf" "/content/"

%%writefile mon_script.sh


#verifier le nombre d'argument
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <VCF_URL> <DOWNLOAD_DIR>"
    exit 1
fi

#arguments automatique 
#VCF ="ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/release/20190312_biallelic_SNV_and_INDEL/ALL.chr15.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.vcf.gz"
#depot ="/content/VCFdirectory"

#definir les arguments
VCF=$1
depot=$2

# telecharger VCF  
#wget -P $depot $VCF
#gunzip $depot/$(basename $VCF)


#wget annovar
wget http://www.openbioinformatics.org/annovar/download/0wgxR2rIVP/annovar.latest.tar.gz
tar -xzvf annovar.latest.tar.gz

# mettre dans le PATH
export PATH=$PATH:$(pwd)

# 4. Télécharger les bases nécessaires refGene 
perl /content/annovar/annotate_variation.pl -buildver hg38 -downdb -webfrom annovar refGene /content/annovar/humandb
# ClinVar (pathogénicité)
perl /content/annovar/annotate_variation.pl -buildver hg38 -downdb -webfrom annovar clinvar_20221231 /content/annovar/humandb

# dbSNP (identifiants de variants)
#!perl /content/annovar/annotate_variation.pl -buildver hg38 -downdb -webfrom annovar avsnp150 /content/annovar/humandb

# gnomAD genome
#!perl /content/annovar/annotate_variation.pl -buildver hg38 -downdb -webfrom annovar gnomad_genome /content/annovar/humandb

#transformer VCF en annovar
perl /content/annovar/convert2annovar.pl -format vcf4old -includeinfo -withfreq "$depot/$(basename "$VCF")" -outfile /content/annovar/input.avinput

#annotation
perl /content/annovar/table_annovar.pl \
     /content/annovar/input.avinput \
    /content/annovar/humandb \
    -buildver hg38 \
    -out /content/annovar/annotated \
   -remove \
   -protocol refGene,clinvar_20221231 \
   -operation g,f \
    -nastring . \
    


#conversion en csv
awk 'BEGIN {OFS=","} {print $1, $2, $3, $4, $5, $6, $7, $8}' /content/annovar/annotated.hg38_multianno.txt > /content/annovar/annotated.csv
