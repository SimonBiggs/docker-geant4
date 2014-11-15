FROM simonbiggs/ipython

MAINTAINER Simon Biggs <mail@simonbiggs.net>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y install cmake build-essential qt4-dev-tools libxmu-dev \
    libmotif-dev libexpat1-dev libboost-all-dev
    
RUN apt-get -y install xfonts-75dpi xfonts-100dpi imagemagick wget

# Download GEANT4
RUN mkdir -p ~/GEANT4/source; \
    cd ~/GEANT4/source; \
    wget http://geant4.web.cern.ch/geant4/support/source/geant4.9.6.p03.tar.gz; \

# Extract source and data files
RUN cd ~/GEANT4/source; \
    tar -xzf geant4.9.6.p03.tar.gz; \

# Install GEANT4
RUN mkdir -p ~/GEANT4/build; \
    cd ~/GEANT4/build; \
    cmake ~/GEANT4/source/geant4.9.6.p03 -DGEANT4_BUILD_MULTITHREADED=ON \
    -DGEANT4_USE_QT=ON -DGEANT4_USE_XM=ON -DGEANT4_USE_OPENGL_X11=ON \
    -DGEANT4_USE_RAYTRACER_X11=ON -DGEANT4_INSTALL_DATA=ON -Wno-dev; \
    make -j`grep -c processor /proc/cpuinfo`; \
    make install; \
    echo ' . geant4.sh' >> ~/.bashrc
    
# Install GEANT4 Python Environment
RUN cd ~/GEANT4/source/geant4.9.6.p03/environments/g4py; \
    sed -e 's/lib64/lib/g' configure > configure_edit_lib64; \
    sed -e 's/python3.3/python3.4 python3.3/g' configure_edit_lib64 > configure_edit_lib64_python34; \
    chmod +x configure_edit_lib64_python34; \
    mkdir -p ~/GEANT4/source/geant4.9.6.p03/environments/g4py/python34; \
    ./configure_edit_lib64_python34 linux64 --with-python3 --enable-openglxm \
    --enable-raytracerx --enable-openglx --with-g4install-dir=/usr/local \
    --with-boost-libdir=/usr/lib/x86_64-linux-gnu \
    --with-boost-python-lib=boost_python-py34 \
    --prefix=~/GEANT4/source/geant4.9.6.p03/environments/g4py/python34; \
    make -j`grep -c processor /proc/cpuinfo`; \
    make install; \
    cd ~/GEANT4/source/geant4.9.6.p03/environments/g4py/python34/lib/Geant4; \
    python3 -c 'import py_compile; py_compile.compile( \"colortable.py\" )'; \
    python3 -c 'import py_compile; py_compile.compile( \"g4thread.py\" )'; \
    python3 -c 'import py_compile; py_compile.compile( \"g4viscp.py\" )'; \
    python3 -c 'import py_compile; py_compile.compile( \"hepunit.py\" )'; \
    python3 -c 'import py_compile; py_compile.compile( \"__init__.py\" )'; \
    python3 -O -c 'import py_compile; py_compile.compile( \"colortable.py\" )'; \
    python3 -O -c 'import py_compile; py_compile.compile( \"g4thread.py\" )'; \
    python3 -O -c 'import py_compile; py_compile.compile( \"g4viscp.py\" )'; \
    python3 -O -c 'import py_compile; py_compile.compile( \"hepunit.py\" )'; \
    python3 -O -c 'import py_compile; py_compile.compile( \"__init__.py\" )'; \
    cd ~/GEANT4/source/geant4.9.6.p03/environments/g4py/python34/lib/g4py; \
    python3 -c 'import py_compile; py_compile.compile( \"emcalculator.py\" )'; \
    python3 -O -c 'import py_compile; py_compile.compile( \"emcalculator.py\" )'; \
    python3 -c 'import py_compile; py_compile.compile( \"mcscore.py\" )'; \
    python3 -O -c 'import py_compile; py_compile.compile( \"mcscore.py\" )'; \
    python3 -c 'import py_compile; py_compile.compile( \"__init__.py\" )'; \
    python3 -O -c 'import py_compile; py_compile.compile( \"__init__.py\" )'; \
    cp -r ~/GEANT4/source/geant4.9.6.p03/environments/g4py/python34/lib/* /usr/local/lib/python3.4/dist-packages/


WORKDIR /root/notebooks/

EXPOSE 8888

CMD ipython3 notebook --no-browser --ip=0.0.0.0 --port=8888
