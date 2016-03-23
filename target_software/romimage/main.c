extern void __fastcall__ rs232_tx (char *str);

int main () {
        
    while (1) {
        rs232_tx ("Hello World!");
    }

    return (0);
}