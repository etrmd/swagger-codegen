#!/bin/bash

function print_usage() {
	script_file_name=$(basename "$0")
    echo "Usage: $script_file_name -d api_descriptor_file.json -o /output/directory/path [-h] [-r] [-v]"
    echo 'Options:'
    echo '-d - Descriptor file path, required parameter.'
    echo '-o - Output directory path, required parameter.'
    echo '-r - Rebuild the code generator, should be used if it is not generated yet.'
    echo '-v - Verbose output'
    echo '-h - Help, displays this message.'
}

if [ $# -eq 0 ] ; then
	print_usage
    exit 0
fi

while getopts "d:o:hrv" opt
do
case $opt in
d) descriptor="$OPTARG"
;;
o) output="$OPTARG"
;;
h) show_help="yes"
;;
r) rebuild="yes"
;;
v) verbose="yes"
;;
esac
done

if [ -n "$show_help" ] ; then 
	print_usage
	exit 0
fi

if [ -z "$descriptor" ] ; then
	echo "-d - Descriptor file path option MUST be specified"
	exit 1
else
	echo "Using '$descriptor' file as JSON Swagger API descriptor file";
fi

if [ -z "$output" ] ; then
	echo "-o - Output directory path option MUST be specified"
	exit 1
else
	echo "Using directory '$output' as an output directory for generated API client";
fi

if [ -n "$rebuild" ] ; then
	echo "Rebuilding the API client codegenarator…"
	if [ -n "$verbose" ] ; then
		mvn clean package -Dmaven.test.skip=true
	else
		mvn clean package -Dmaven.test.skip=true > /dev/null 2>&1
	fi
fi

pushd `dirname $0` > /dev/null
script_dir=`pwd`
popd > /dev/null

echo "Generating API client…"

rm -rf "$script_dir/gen/"
mkdir "$script_dir/gen"

if [ -n "$verbose" ] ; then
	java -jar "$script_dir/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar" generate -i "$descriptor" -l objc -o "$script_dir/gen" --additional-properties reactiveObjC=true
else
	java -jar "$script_dir/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar" generate -i "$descriptor" -l objc -o "$script_dir/gen" --additional-properties reactiveObjC=true > /dev/null 2>&1
fi

echo "Preparing files at \"$output\""
cp -R "$script_dir/gen/SwaggerClient/" "$output"

echo "Done, enjoy your API client"
