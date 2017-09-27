mainMenu =  [   'Format Disk', 
                'Read Disk Info',
                'Write To Disk',
                'Read File Table',
                'Open .text file'
            ]
           
def displayMenu( menuLst ) :
    pos = 0;
    for i in menuLst :
        print('\n [\t{}\t:\t{}\t]'.format( pos, i ))
        pos += 1
def menu() :
    while True :
        
