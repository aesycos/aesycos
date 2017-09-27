#include <fstream>
#include <iostream>

typedef char* string;

char* prompt( const char* msg );
int readBin( char* fileName, char access);

int openBin( char* fileName = 0, char access = 'r' ) {
	char* fn = new char;
	if (fileName == 0) {
		fn = prompt("Please enter a file name: ");
	} else {
		fn = fileName;
	}
	std::ifstream fin(fn, std::ios::binary);
	if (!fin) {
		std::cout << "Unable to open " << fn << " for reading.\n";
		return(1);
	};
	std::cout << "Successfully opened " << fn << " for reading.\n";
	return(0);

}


char*	prompt( const char* msg ) {
		char* value = new char;
		std::cout << msg;
		std::cin >> value;
		return(value);
}

int getPrompt( const char* PS1 ) {
    char* value = prompt(PS1);
    if (value == "bye") {
        return 1;
    };
    return 0;
}

int main() {
    openBin();
    const char* PS1 = ":> ";
    while (true) {
        int value = getPrompt(PS1);
        if (value == 1) {
            break;
        };
    };
    return 0;
}
