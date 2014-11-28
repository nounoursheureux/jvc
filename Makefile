CFLAGS = -g -Wall -Wextra -pedantic -Wshadow 
LIBS = -ltinyxml -lcurl

all: jvc

jvc: jvc.o
	g++ $^ -o jvc $(CFLAGS) $(LIBS)

%.o: %.c 
	g++ -o $@ -c $< $(LIBS) $(CFLAGS)

clean: 
	rm -rf *.o 

mrproper: clean
	rm futilewm
