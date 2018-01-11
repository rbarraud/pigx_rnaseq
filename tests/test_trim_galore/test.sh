#!/usr/bin/bash

# usage: 
# > ./test.sh  <path to source directory> <path to executable in the environment>

srcdir=$1
EXEC=$2

if [ -z ${srcdir} ]
then 
  echo "ERROR: provide path to source directory"
  exit 1
fi

if [ -z ${EXEC} ]
then 
  echo "ERROR: provide path to tool's executable"
  exit 1 
fi 

test_folder="${srcdir}/tests/test_trim_galore"

#the single-end read file provided as input to trim galore
input1="${test_folder}/input_files/sample.read1.fastq.gz"
input2="${test_folder}/input_files/sample.read2.fastq.gz" 

if [ ! -d ${srcdir} ]
then 
  echo "ERROR: source directory at '${srcdir}' doesn't exist"
  exit 1
fi

if [ ! -f ${EXEC} ]
then
  echo "ERROR: path to tool's executable at '${EXEC}' doesn't exist" 
  exit 1
fi

if ! test -x ${EXEC}
then 
  echo "ERROR: permission denied to execute ${EXEC}"
  exit 1
fi 

if ! test -d ${test_folder} 
then 
  echo "ERROR: test folder at ${test_folder} doesn't exist" 
  exit 1
fi

if ! test -f ${input1}
then 
  echo "ERROR: input file at ${input1} doesn't exist"
  exit 1
fi

if ! test -f ${input2}
then
  echo "ERROR: input file at ${input2} doesn't exist"
  exit 1
fi


#####################################

# a function to test reads processed by trim_Galore
test_processed_reads () {
  result=$1
  read_file=$2
  expected_count=$3
  mode=$4 
  if ! test -f ${result}
  then
    echo "ERROR: trim_galore failed on ${mode} mode. Could not produce ${result}"
  exit 1
  else
    reads_processed=`grep "sequences processed in total" ${result} | awk '{print int( $1 )}'`
    if [ ! ${reads_processed} -eq ${expected_count} ]
    then 
      echo "ERROR: trim_galore failed at ${mode} mode.
       The number of processed reads (found ${reads_processed}) doesn't match 
       the expected number of reads (expected: ${expected_count})
       in the input file at ${read_file}"
      exit 1
    fi
  fi
}

#Test trim_galore on single-end mode
mkdir ${test_folder}/output_single_end
${EXEC} -o ${test_folder}/output_single_end ${input1} >> ${test_folder}/output_single_end/log.out 2>&1 
result_se="${test_folder}/output_single_end/sample.read1.fastq.gz_trimming_report.txt"

test_processed_reads ${result_se} ${input1} 50 single-end

echo "Congrats! trim_galore passed tests on single-end mode"

#Test trim_galore on paired-end mode
mkdir ${test_folder}/output_paired_end
${EXEC} -o ${test_folder}/output_paired_end --paired ${input1} ${input2} >> ${test_folder}/output_paired_end/log.out 2>&1
result_pe_1="${test_folder}/output_paired_end/sample.read1.fastq.gz_trimming_report.txt"
result_pe_2="${test_folder}/output_paired_end/sample.read2.fastq.gz_trimming_report.txt"

test_processed_reads ${result_pe_1} ${input1} 50 paired-end
test_processed_reads ${result_pe_2} ${input2} 50 paired-end

echo "Congrats! trim_galore passed tests on paired-end mode"






