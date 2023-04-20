#!/usr/bin/env bash
# 
# Script para geração automatizada do Manual em Markdown à partir de um BD BrERP/iDempiere
# 
# Antes de executar, assegure-se de ter o psql instalado e configurado em seu ambiente
#
# No servidor é necessário ter as extensions unaccent e plpython3u instaladas

DOTFILE="../config.env"
OUTPUT_DIR="./docs"
IMG_DIR="./img"
IMG_TEMPLATE_DIR="./img_all"
DOCUSAURUS_MANUAL_DIR="../../documentacao/docs/system-manual/brerp"
DOCUSAURUS_MANUAL_IMG_DIR="../../documentacao/static/img/system-manual/brerp"

REQUIRED_TOOLS=(
  "psql"
)

for tool in ${REQUIRED_TOOLS[@]}; do
  if ! command -v ${tool} >/dev/null; then
    echo "${tool} is required ..."
    exit 1
  fi
done

if [[ ! -f ${DOTFILE} ]]; then
  echo "File ${DOTFILE} is required ..."
  exit 1
fi

source ${DOTFILE}

# remove as pastas temporárias
rm -rf ${OUTPUT_DIR}
rm -rf ${IMG_TEMPLATE_DIR}

# recria as pastas que serão utilzadas
mkdir -p ${OUTPUT_DIR}/{form,info,process,report,task,window,workflow}
mkdir ${IMG_TEMPLATE_DIR}
mkdir ${IMG_DIR}

# exporta a senha do postgresql
export PGPASSWORD=$PGPASSWORD

# cria os scripts intermediarios de geração 
psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -U ${PGUSER} -f 02_create_view_pg.sql 
psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -U ${PGUSER} -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Form_TEMPLATE_PAGE_pg.sql > ${OUTPUT_DIR}/script_gen_wiki_files_Form_TEMPLATE_PAGE_pg.sh
psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -U ${PGUSER} -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Info_TEMPLATE_PAGE_pg.sql > ${OUTPUT_DIR}/script_gen_wiki_files_Info_TEMPLATE_PAGE_pg.sh
psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -U ${PGUSER} -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Process_TEMPLATE_PAGE_pg.sql > ${OUTPUT_DIR}/script_gen_wiki_files_Process_TEMPLATE_PAGE_pg.sh
psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -U ${PGUSER} -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Report_TEMPLATE_PAGE_pg.sql > ${OUTPUT_DIR}/script_gen_wiki_files_Report_TEMPLATE_PAGE_pg.sh
psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -U ${PGUSER} -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Task_TEMPLATE_PAGE_pg.sql > ${OUTPUT_DIR}/script_gen_wiki_files_Task_TEMPLATE_PAGE_pg.sh
psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -U ${PGUSER} -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Window_TEMPLATE_PAGE_pg.sql > ${OUTPUT_DIR}/script_gen_wiki_files_Window_TEMPLATE_PAGE_pg.sh
psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -U ${PGUSER} -q -P tuples_only=on -P footer=off -Pborder=0 -P format=unaligned -f script_gen_wiki_files_Workflow_TEMPLATE_PAGE_pg.sql > ${OUTPUT_DIR}/script_gen_wiki_files_Workflow_TEMPLATE_PAGE_pg.sh

# executa os scripts criados
cd ${OUTPUT_DIR}
chmod +x *.sh
./script_gen_wiki_files_Form_TEMPLATE_PAGE_pg.sh
./script_gen_wiki_files_Info_TEMPLATE_PAGE_pg.sh
./script_gen_wiki_files_Process_TEMPLATE_PAGE_pg.sh
./script_gen_wiki_files_Report_TEMPLATE_PAGE_pg.sh
./script_gen_wiki_files_Task_TEMPLATE_PAGE_pg.sh
./script_gen_wiki_files_Window_TEMPLATE_PAGE_pg.sh
./script_gen_wiki_files_Workflow_TEMPLATE_PAGE_pg.sh

# remove os scripts intermediarios
rm -rf *.sh

# volta ao diretório principal
cd ..

# limpa o diretorio atual da documentação

# copia os novos arquivos gerados
rm -rf ${DOCUSAURUS_MANUAL_DIR}/*
cp -pr ${OUTPUT_DIR}/* ${DOCUSAURUS_MANUAL_DIR}/
cp ${IMG_TEMPLATE_DIR}/* ${DOCUSAURUS_MANUAL_IMG_DIR}/
cp ${IMG_DIR}/* ${DOCUSAURUS_MANUAL_IMG_DIR}/

# copia os arquivos de categoria para ajustar exibição no menu
cp static/form__category_.json ${DOCUSAURUS_MANUAL_DIR}/form/_category_.json 
cp static/info__category_.json ${DOCUSAURUS_MANUAL_DIR}/info/_category_.json 
cp static/proces__category_.json ${DOCUSAURUS_MANUAL_DIR}/process/_category_.json 
cp static/report__category_.json ${DOCUSAURUS_MANUAL_DIR}/report/_category_.json 
cp static/task__category_.json ${DOCUSAURUS_MANUAL_DIR}/task/_category_.json 
cp static/window__category_.json ${DOCUSAURUS_MANUAL_DIR}/window/_category_.json 
cp static/workflow__category_.json ${DOCUSAURUS_MANUAL_DIR}/workflow/_category_.json 

# gera o arquivo de indice
cd ../genwikiindex
./script_gen_wiki_file_Index_pg.sh > index.md

# copia o arquivo de indice
cp index.md ${DOCUSAURUS_MANUAL_DIR}
