# -*- coding: utf-8 -*-
import os

projects = {
    '01_basics_oop': {
        'name': 'Basics OOP - Classes & Inheritance',
        'files': ['main.pb'],
        'output': 'basics_oop.exe'
    },
    '02_responsive_layout': {
        'name': 'Responsive Layout - Grid, StackPanel & DockPanel',
        'files': ['main.pb'],
        'output': 'responsive_layout.exe'
    },
    '03_simple_mvvm': {
        'name': 'Simple MVVM - Counter & Bindings',
        'files': ['Main.pb', 'SimpleConstants.pbi', 'views/SimpleView.pbi', 'views/SimpleView.xml', 'viewmodels/SimpleViewModel.pbi'],
        'output': 'simple_mvvm.exe'
    },
    '04_todo_app': {
        'name': 'Todo App - Observable Collections & MVVM',
        'files': ['main.pb', 'constants/AppConstants.pbi', 'models/TaskModel.pbi', 'viewmodels/TaskViewModel.pbi', 'views/MainWindow.pbi'],
        'output': 'todo_app.exe'
    }
}

for folder, pinfo in projects.items():
    pbp_path = os.path.join('examples', folder, f'{folder}.pbp')
    files_xml = []
    for idx, fn in enumerate(pinfo['files'], 1):
        win_fn = fn.replace('/', '\\')
        files_xml.append(f'    <file name="{win_fn}">\n      <config load="0" scan="1" panel="1" warn="1" lastopen="0" sortindex="{idx}" panelstate="+"/>\n    </file>')
    files_str = '\n'.join(files_xml)

    first_file = pinfo['files'][0].replace('/', '\\')

    pbp_content = f'''<?xml version="1.0" encoding="UTF-8"?>

<project xmlns="http://www.purebasic.com/namespace" version="1.0" creator="PureBasic 6.40 (Windows - x64)">
  <section name="config">
    <options closefiles="1" openmode="0" name="{pinfo['name']}"/>
  </section>
  <section name="data">
    <explorer view="" pattern="0"/>
    <log show="1"/>
    <lastopen date="2026-09-08 12:00" user="MicrodevWeb" host="WORKSTATION"/>
  </section>
  <section name="files">
{files_str}
  </section>
  <section name="targets">
    <target name="Default Target" enabled="1" default="1">
      <inputfile value="{first_file}"/>
      <outputfile value="{pinfo['output']}"/>
      <options thread="1" xpskin="1" dpiaware="1" debug="1" optimizer="0"/>
    </target>
  </section>
</project>
'''
    with open(pbp_path, 'w', encoding='utf-8') as f:
        f.write(pbp_content)
    print(f'Created {pbp_path}')
