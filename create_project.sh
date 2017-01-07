#!/bin/bash

# Determine the root directory of the project.
if [ -z "$1" ]; then
    echo "Please specify project root directory!"
    exit
fi
PROJECT_ROOT_DIR=$1

PROJECT_NAME=`basename $PROJECT_ROOT_DIR`

# Determine full main class name.
if [ -z "$2" ]; then
    echo "Please specify full name of main java class!"
    exit
fi
FULL_CLASS_NAME=$2
SIMPLE_CLASS_NAME=${FULL_CLASS_NAME##*.}
PACKAGE_NAME=${FULL_CLASS_NAME%.*}
MAIN_CLASS_DIR=$PROJECT_ROOT_DIR/src/`echo ${FULL_CLASS_NAME%.*} | sed -r 's/\./\//g'`

echo "Project root dir: "$PROJECT_ROOT_DIR
echo "Project name: "$PROJECT_NAME
echo "Full main class name: "$FULL_CLASS_NAME
echo "Simple main class name: "$SIMPLE_CLASS_NAME
echo "Package name: "$PACKAGE_NAME
echo "Main class directory: "$MAIN_CLASS_DIR

if [ ! -d $MAIN_CLASS_DIR ]; then
    mkdir -p $MAIN_CLASS_DIR
fi

printf "Main-Class: %s\n" $FULL_CLASS_NAME > $PROJECT_ROOT_DIR/manifest.mf
printf "package %s;\n\
\n\
public class %s {\n\
    public static void main(String[] args) {\n\
        //TODO Place your code here.
    }\n\
}" \
$PACKAGE_NAME $SIMPLE_CLASS_NAME > $MAIN_CLASS_DIR/$SIMPLE_CLASS_NAME.java

printf "#!/bin/bash\n\
\n\
# compiling java sources\n\
if [ ! -d ./classes ]; then\n\
    mkdir ./classes\n\
fi\n\
find . -name \"*.java\" -print | xargs javac -d ./classes\n\
\n\
# building jar file\n\
jar -cmf manifest.mf %s.jar -C ./classes ." $PROJECT_NAME  > $PROJECT_ROOT_DIR/build.sh
chmod 755 $PROJECT_ROOT_DIR/build.sh