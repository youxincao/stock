# use strict ;
# use warnings ;

use DBI ;
use LWP::Simple ;

# input variable
my $code = "300251";

# get the stock info
my $url =  "http://money.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/".$code.".phtml" ;
my $content = get $url ;
my @ary = split(/\n/ , $content ) ;
my $yearstart = '0' ;
my @years ;
my @stocks ;
my @stock ;
my @year ;
my $address ;
my $index ;
my @date ;
my @data ;
my $x ;
 
foreach my $line (@ary) {

    # parse the year 
    if ( $line =~ m/<select name="year"/) {
        $yearstart = '1' ;
    }

    # parse the year 
    if ( $line =~ m/option value=/) {
        if ( $yearstart ) {
            # print $line  . "\n";
            @year = $line =~ m!<option value.*?>(.*)</option>! ;
            if ( @year ) {
                unshift  @years , $year[0] ;
            }
        }
    }

    #end of the year 
    if ( $line =~ m/<\/select>/ ) {
        $yearstart = '0'
    }
}

# foreach my $year (@years) {
#     print $year , "\n";
# }
foreach my $year (@years) {
    
    foreach my $jidu ( ("1" ,"2" ,"3" ,"4" )) {
        # generate the address 
        $address = $url."?year=".$year."&jidu=".$jidu ;
        print $address."\n" ;
        
        $content = get $address;
        @ary = split( /\n/ , $content ) ;

        $index = 0 ;
        
        foreach my $line (@ary) {
            if ( @date = $line =~ m!(\d{4}-\d{2}-\d{2}).*</div></td>!) {
             
                @stock = (  $date[0] ,
                            0.0 ,
                            0.0 ,
                            0.0 ,
                            0.0 ,
                            0.0 ,
                            0.0 );
                $index = 1 ;
                    
            }
            
            if ( @date =  $line =~ m!(\d{4}-\d{2}-\d{2}).*</a>!) {

                @stock = (  $date[0] ,
                            0.0 ,
                            0.0 ,
                            0.0 ,
                            0.0 ,
                            0.0 ,
                            0.0 );
                
                $index = 1 ;
            }

            if ( @data = $line =~ m!<td.*?><div align="center">([\d\.]*)</div></td>! ) {
                # if ( $index == 1 ) {
                #     $stock{"price_begin"} = $data[0] ;
                #     $index ++ ;
                # } elsif ( $index == 2 ) {
                #     $stock{"price_max"} = $data[0] ;
                #     $index ++ ;
                # }elsif ( $index == 3) {
                #     $stock{"price_end"} = $data[0] ;
                #     $index ++ ;
                #  }elsif ( $index == 4 ) {
                #      $stock{"price_min"} = $data[0] ;
                #      $index ++ ;
                #  }elsif ( $index == 5 ) {
                #      $stock{"trade_amount"} = $data[0];
                #      $index ++ ;                                               
                #  }elsif ( $index == 6 ) {
                #      $stock{"trade_price"} = $data[0];
                #      $index = 0  ;
                $stock[$index] = $data[0];
                $index ++ ;
                
                if ( $index ==7 ) {
                    push(@stocks , @stock  ) ;
                    $index = 1 
                } 
                     
            }
        }                
    }
}



my $dbh = DBI->connect("DBI:mysql:database=stock;host=localhost" , "root" , "19890919" ,
                       {'RaiseError' => 1 } ) ;

my $stock_length = scalar( @stocks ) / 7  ;
for (my $var = 0; $var < $stock_length ; $var++) {
     print "$stocks[ 7 * $var ] $stocks[ 7 * $var + 1] $stocks[ 7 * $var + 2 ] $stocks[ 7 * $var + 3 ] $stocks[ 7 * $var + 4] $stocks[ 7 * $var + 5] $stocks[ 7 * $var + 6] \n";
     $dbh->do('INSERT INTO stock_record(code , date , price_begin , price_max , price_end , price_min , trade_amount , trade_price ) VALUES ( ? , ? , ? , ? , ? , ? , ? , ? )' ,
              undef ,
              $code , $stocks[7*$var],$stocks[7*$var + 1],$stocks[7 *$var + 2 ], $stocks[7 * $var + 3 ],$stocks[7 * $var + 4],$stocks[7 * $var + 5],$stocks[7 * $var + 6] );
     
}

$dbh->disconnect() ;
