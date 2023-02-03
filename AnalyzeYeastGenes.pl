#Ming Creekmore
#A program to determine the GC content of yeast genes
#as well as get the log2 transcription levels for the specified
#yeast gene

#open files
use Cwd;
my $dir = getcwd;
$yeastgene = $dir."/YeastGenes";
opendir(DIR, $yeastgene) or die "can't open directory $yeastgene:$!"; print"\n";
mkdir "AnalyzedGenes";
$fileRNA = "./Yeast_RNAseq/"."Nagalakshmi_2008_5UTRs_V64.gff3";
open(INFILE2, $fileRNA) or die "Cannot open file";

#read each file in directory
while($filename = readdir DIR) {
    $ORFname = substr($filename, 0, 7);

    #only open if the filename is a yeast gene 
    $filelocation = $yeastgene."/"."$filename";
    if (length $ORFname == 7){
        open (INFILE, $filelocation) or die "Cannot open file";
        print $ORFname."\n";
    }
    else {
        next;
    }
    open (OUTFILE, ">"."./AnalyzedGenes/"."$ORFname".".txt") || die " could not open output file\n";

    #find corresponding log 2 transcription value in 5 RNA file data
    #read DNA in file and calculate GC content
    while(<INFILE>) {

        #looping through RNA data to find specific yeast gene
        #and get the log2transcription number
        while(my $RNAfile = <INFILE2>) {
            if( $RNAfile =~ m/$ORFname/) {
                #parse through file to get log2transcription number
                @line_segments = split(/\s+/, $RNAfile); #split whitespace
                $line_segment = @line_segments[8];
                @transLevel_test = split(";", $line_segment);  #split on semicolon
                $transLevel_test = @transLevel_test[2];
                $transLevel_test = substr($transLevel_test, 25, 5); #only get numbers
                print "Log2 Transcription Value: ".$transLevel_test."\n";
                print OUTFILE $ORFname."\nLog2TranscriptionValue: ".$transLevel_test."\t";
            }
        }

        #removes return carriages
        chomp;
        $test = $_;

        #see if line is the heading or the DNA
        #if DNA, then find GC content
        #For some unknown reason >Scer won't match with anything
        if($_ =~ /A/ || $_=~ /T/ || $_ =~ /G/ || $_ =~ /C/){
            $GCCount = 0;
            foreach $base (split('', $_)) {
                if($base eq "G" || $base eq "C") {
                    $GCCount++;
                }
            }
            $GCfreq = $GCCount/(length $_);

            #print findings to screen and outfile
            print "GC Count: ".$GCCount."\t";
            print "Base Total: ".(length $_)."\t";
            print "GC Freq: ".$GCfreq."\n\n";
            print OUTFILE "GC Count: ".$GCCount.
                "\t"."Base Total: ".(length $_)."\t"."GC Freq: ".$GCfreq."\n";
        }
        
    }
    #need to reset the RNA data file so we can read the it again
    seek INFILE2, 0, 0;
}

    
print "end program\n";
exit;
