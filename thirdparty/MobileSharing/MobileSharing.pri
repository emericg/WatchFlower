QT += core gui qml

SOURCES += $${PWD}/SharingUtils.cpp \
           $${PWD}/SharingApplication.cpp

HEADERS += $${PWD}/SharingUtils.h \
           $${PWD}/SharingApplication.h

INCLUDEPATH += $${PWD}

android {
    QT += core-private

    SOURCES += $${PWD}/SharingUtils_android.cpp
    HEADERS += $${PWD}/SharingUtils_android.h

    # Add this line to the dependencies {} section of 'build.gradle' file:
    #implementation 'androidx.appcompat:appcompat:1.6.1'
    #implementation 'androidx.core:core:1.6.1'

    # And this line in 'gradle.properties' file:
    #android.useAndroidX=true

    # These files are from the parent project:
    #ANDROID_PACKAGE_SOURCE_DIR = $${PWD}/android
    #OTHER_FILES += $${PWD}/src/io/emeric/qmlapptemplate/QShareActivity.java \
    #               $${PWD}/src/io/emeric/utils/QShareUtils.java \
    #               $${PWD}/src/io/emeric/utils/QSharePathResolver.java

    # Rename these to match your project:
    #io/emeric/utils
    #io.emeric.qmlapptemplate
    #io_emeric_qmlapptemplate
}

ios {
    LIBS += -framework UIKit

    SOURCES += $${PWD}/SharingUtils_ios.mm \
               $${PWD}/docviewcontroller_ios.mm

    HEADERS += $${PWD}/SharingUtils_ios.h \
               $${PWD}/docviewcontroller_ios.h
}
