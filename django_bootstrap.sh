#!/bin/bash

if [ $# -ne 2 ]
then
    echo "Error in $0 - Invalid Argument Count"
    echo "Syntax: $0 project_name desidered_heroku_name"
    exit
fi

project_name=$1
heroku_name=$2
project_name_prj=$1'_prj'

# check if the dir already exists
if [ -d $project_name_prj ]; then
    echo "That directory ("$project_name_prj") already exists"
    exit
fi


mkdir  $project_name_prj
cd  $project_name_prj


echo "Django==1.3.1" > requirements.txt
echo "psycopg2" >> requirements.txt
echo "south" >> requirements.txt

echo "Django==1.3.1" > requirements_dev.txt
echo "south" >> requirements_dev.txt
echo coverage >> requirements_dev.txt
echo django-jenkins >> requirements_dev.txt
echo django-coverage >> requirements_dev.txt


virtualenv 'py_'$project_name --no-site-packages
source 'py_'$project_name/bin/activate

pip install -r requirements_dev.txt

django-admin.py startproject  $project_name

# create file dirs
mkdir -p $project_name/static
mkdir -p $project_name/restricted
mkdir -p $project_name/template


echo "web: $project_name/run_heroku_run.sh" > Procfile
echo "#!/bin/bash
. bin/activate
pip -E . install --upgrade gunicorn
cd $project_name
../bin/gunicorn_django -b 0.0.0.0:$PORT -w 1" > $project_name/run_heroku_run.sh
chmod +x $project_name/run_heroku_run.sh
git init

git commit -m "Initial commit"
# edit the settings file
# imports
sed -i "s/DEBUG = True/import os\nimport sys\n\nPROJECT_DIR = <project dir>\nPROJECT_ROOT = os.path.dirname(PROJECT_DIR)\n\nDEBUG = True/" $project_name/settings.py
# db
sed -i "s/'ENGINE': 'django.db.backends.',.*$/'ENGINE': 'django.db.backends.sqlite3',/" $project_name/settings.py
sed -i "s/'NAME': '',.*$/'NAME': os.path.join(PROJECT_ROOT, 'development.db'),/" $project_name/settings.py
# location
sed -i "s/TIME_ZONE = '[^']*'/TIME_ZONE = 'Europe\/Rome'/" $project_name/settings.py
sed -i "s/LANGUAGE_CODE = '[^']*'/LANGUAGE_CODE = 'it-it'/" $project_name/settings.py
# files
sed -i "s/MEDIA_ROOT = '[^']*'/MEDIA_ROOT = os.path.join(PROJECT_ROOT, 'files', 'restricted')/" $project_name/settings.py
sed -i "s/MEDIA_URL = '[^']*'/MEDIA_URL = '\/media\/'/" $project_name/settings.py
sed -i "s/STATIC_ROOT = '[^']*'/STATIC_ROOT = os.path.join(PROJECT_ROOT, 'files', 'static')/" $project_name/settings.py
sed -i "s/STATIC_URL = '[^']*'/STATIC_URL = '\/static\/'/" $project_name/settings.py
sed -i "s/ADMIN_MEDIA_PREFIX = '[^']*'/ADMIN_MEDIA_PREFIX = '\/static\/admin\/'/" $project_name/settings.py
# installed apps
sed -i "s/    # 'django.contrib.admindocs',/    # 'django.contrib.admindocs',\n    'south', \n 'django-coverage' /" $project_name/settings.py
sed -i "s/    # 'django.contrib.admin',/     'django.contrib.admin', /" $project_name/settings.py


# templates
sed -i "s/TEMPLATE_DIRS = (/TEMPLATE_DIRS = (\n    os.path.join(PROJECT_DIR, 'templates'),/" $project_name/settings.py

#Admin urls
sed -i "s/# from django.contrib import admin/from django.contrib import admin / "$project_name/urls.py
sed -i "s/# admin.autodiscover()/admin.autodiscover()/ " $project_name/urls.py
sed -i "s/    # url(r'\^admin/', include(admin.site.urls)),/    url(r'\^admin\/', include(admin.site.urls)),/ " $project_name/urls.py






echo *.mo > .gitignore
echo *.egg-info >> .gitignore
echo *.egg >> .gitignore
echo *.EGG >> .gitignore
echo *.EGG-INFO >> .gitignore
echo bin >> .gitignore
echo 'py_'$project_name >> .gitignore
echo build >> .gitignore
echo develop-eggs >> .gitignore
echo downloads >> .gitignore
echo eggs >> .gitignore
echo fake-eggs >> .gitignore
echo parts >> .gitignore
echo dist >> .gitignore
echo .installed.cfg >> .gitignore
echo .hg >> .gitignore
echo .bzr >> .gitignore
echo .svn >> .gitignore
echo *.pyc >> .gitignore
echo *.pyo >> .gitignore
echo *.tmp* >> .gitignore
echo *.db >> .gitignore


git add -A
git commit -m "Bootstrapped project - initial commit"

#TODO verify if project exists
# heroku create $heroku_name --stack cedar
