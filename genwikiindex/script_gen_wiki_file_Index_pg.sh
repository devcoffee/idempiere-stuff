
#!/bin/bash
# 
# Script para geração automatizada do Indice do Manual em Markdown à partir de um BD BrERP/iDempiere
# 
# No servidor é necessário ter as extensions unaccent e plpython3u instaladas

DOTFILE="../config.env"

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


# exporta a senha do postgresql
export PGPASSWORD=$PGPASSWORD
psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -U ${PGUSER}  -f QSS_GET_TABLES_FROM_WINDOW_pg.sql > /dev/null

opentable="N"

echo "# BrERP"

( echo "copy (" ; cat Query_pg.sql; echo ") to stdout with csv;" ) |
psql -h ${PGHOST} -p ${PGPORT} -d ${PGDATABASE} -U ${PGUSER} -q -t -A -F"," | sed -e 's/"//g' |
while IFS=, read node_id parent_id level seqno issummary name type action technical id beta name_encoded rest 
do
    name=`echo $name | tr '|' ','`
	name_encoded=`echo $name_encoded | tr '|' ','`
    sec=""
    if [ "$level" -lt 4 ]
    then
        if [ "$issummary" = "Y" ]
		then
	    	sec=`head -c $level < /dev/zero | tr '\0' '#'`
		fi
    fi
    if [ "$issummary" = "Y" ]
    then
		if [ "$opentable" = "Y" ]
		then
            # Table is Open -> Close Table
	   		echo "</table>"
			echo
			echo
	    	opentable="N"
		fi
		if [ "$level" -eq 1 ]
		then
			# Insert Empty Line
			echo
			echo
		fi
        # Title
		echo "$sec $name"
		echo
    else
	 	# Table Format
		if [ "$opentable" = "Y" ] && [ "$level" -eq 1 ]
		then
		 	# Table is Open -> Close Table
	   		echo "</table>"
			echo
			echo
	    	opentable="N"
		fi
        # Table Format
		if [ "$opentable" = "N" ]
		then
			# Flag activated to indicate Table is Open
			echo "<table>"
			#echo "|-"
			opentable="Y"
		fi
		
        echo '<tr>'
		echo '<td>'
		echo ''
		namet=`echo $name | tr ' ' '_' | tr '/' '-'`
		actionl=`echo "$action" | tr '[:upper:]' '[:lower:]'`
		echo "[${name}](./${actionl}/${name_encoded}_${action}_ID-${id}_v10.0.0.md)"
		echo 
		echo -n '</td><td>'
		echo -n $action
		echo '</td><td><small>'
		echo
		echo $technical
		echo
		echo '</small></td>'
		echo '</tr>'
		echo
    fi
done
echo "</table>"
