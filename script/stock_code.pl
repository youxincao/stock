use strict;
use LWP::Simple ;
use Encode ;
use utf8;
use DBI;


binmode( STDIN , ':encoding(utf8)');

my $base_url = "http://vip.stock.finance.sina.com.cn/q/go.php/vIR_RatingNewest/index.phtml?num=40";
my $last_count = 0 ;
my $page = 1 ;


while  ( $last_count == 0 || $last_count == 40 ) {
    my $url = $base_url."&p=$page";
    print $url ."\n";   
    insertStockInfo($url);
    $page ++ ;
}

sub insertStockInfo {
    my $url = $_[0] ;
    my $content = get $url ;
    my @arr_content = split(/\n/ , $content ) ;
    my $index = 0 ;
    my @arr_stockinfo ;

    foreach my $line (@arr_content) {
        if (my @code =  $line =~ m/<td><a\ href="http:\/\/biz.*>([0-9]+)<\/a><\/td>/ ) {
            # print $code[0] . "\n";
            # print $line ."\n";
            if ( $index == 0 ) {
                push(@arr_stockinfo , @code[0]);
                $index ++ ;
            }
        
        }

        if (my @name = $line =~ m!<td><a\ href="http://biz.*><span.*>(.*)</span></a></td>! ) {
            if ( $index = 1 ) {
                # print decode( "gb2312" , @name[0] ) . "\n";
                $index ++ ;
                push(@arr_stockinfo , @name[0]);
            }
        }

        if ( my @type = $line =~ m!<td>(.*)</td>$!) {
            
            if ( $index != 0 ) {
                $index ++ ;
            }
            if ( $index == 7 ) {
                # print decode("gb2312" , @type[0] ) . "\n" ;
                push(@arr_stockinfo , @type[0]);
                $index = 0;
            }
        }
    }

    my $dbh = DBI->connect("DBI:mysql:database=stock;host=localhost" , "root" , "19890919" ,
                           {
                               'RaiseError' => 1 } ) ;

    $dbh->do("SET NAMES 'utf8'");

    $last_count = @arr_stockinfo / 3 ;
    
    for (my $var = 0; $var < @arr_stockinfo / 3 ; $var++) {

        my $code = @arr_stockinfo[$var * 3 ];
        my $sth = $dbh->prepare('SELECT code from stock_info where code ='.$code );
        $sth->execute();
        my $result = $sth->fetchrow_hashref() ;
        
        if (!$result->{code} ) {
            $dbh->do('INSERT INTO stock_info(code , name , type ) VALUES ( ? , ? , ?)' ,
                     undef ,
                     @arr_stockinfo[$var * 3 ] ,
                     encode( "utf-8" , decode('gb2312' , @arr_stockinfo[$var * 3 +1]) ),
                     encode( "utf-8" , decode('gb2312' , @arr_stockinfo[$var * 3 +2]) ) )
                or die "Insert into failed code @arr_stockinfo[$var*3]";
        }
    } 
        
    $dbh->disconnect();
}
