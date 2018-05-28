FROM python:2.7-stretch

RUN apt-get update && apt-get install -y libusb-1.0-0-dev
RUN wget https://www.phidgets.com/downloads/phidget22/libraries/linux/libphidget22.tar.gz && \
  tar zxf libphidget22.tar.gz && \
  cd libphidget* && \
  ./configure --prefix=/usr && \
  make && \
  make install && \
  make clean

RUN apt-get install -y unzip
RUN wget https://www.phidgets.com/downloads/phidget22/libraries/any/Phidget22Python.zip && \
  unzip Phidget22Python.zip && \
  cd Phidget22Python && \
  python setup.py install

RUN mkdir /srv/pedal
COPY pedal.py /srv/pedal/
WORKDIR /srv/pedal

# extra option for URL, default http://localhost:3000/input
CMD ["python","pedal.py"]
