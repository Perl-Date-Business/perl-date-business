# NAME

    Date::Business - fast calendar and business date calculations

# SYNOPSIS

    use Date::Business;

    All arguments to the Date::Business constructor are optional.

    # simplest case, default is today's date (localtime)
    $d = new Date::Business();           

    # initialize with date string, 
    # offset in business days is optional
    $d = new Date::Business(DATE => '19991124' [, OFFSET => <integer>]); 

    # initialize with another Date::Business object
    # offset in business days is optional
    $x = new Date::Business(DATE => $d [, OFFSET => <integer>]);         

    # initialize with holiday function (see Holidays, below)
    $d = new Date::Business(HOLIDAY => \&holiday); 

    # force weekends/holidays to the previous or next business day
    $d = new Date::Business(FORCE => 'prev'); # Friday (usually)
    $d = new Date::Business(FORCE => 'next'); # Monday (usually)

    $d->image(); # returns YYYYMMDD string
    $d->value(); # returns Unix time as integer

    $d->day_of_week();     # 0 = Sunday

    $d->datecmp($x);       # are two dates equal?
    $d->eq($x);            # synonym for datecmp
    $d->lt($x);            # less than
    $d->gt($x);            # greater than

    Calendar date functions
    $d->next();         # next calendar day
    $d->prev();         # previous calendar day
    $d->add(<offset>);  # adds n calendar days
    $d->sub(<offset>);  # subtracts n calendar days
    $d->diff($x);       # difference between two dates  
      
    Business date functions
    $d->nextb();        # next business day
    $d->prevb();        # previous business day
    $d->addb(<offset>); # adds n business days
    $d->subb(<offset>); # subtracts n business days
    $d->diffb($x);      # difference between two business dates  
    $d->diffb($x, 'next'); # treats $d weekend/holiday as next business date
    $d->diffb($x, 'next', 'next'); # treats $x weekend/holiday as above

# DESCRIPTION

Date::Business provides the functionality to perform simple date
manipulations quickly. Support for calendar date and
business date math is provided.

Business dates are weekdays only. Adding 1 to a weekend returns
Monday, subtracting 1 returns Friday.

The difference in business days between Friday and the following
Monday (using the diffb function) is one business day. The number
of business days between Friday and the following Monday (using the
betweenb function) is zero.

# EXAMPLE

Date::Business works very well for iterating over dates,
and determining start and end dates of arbitray n business day
periods (e.g. consider how to perform a computation for
a series of business days starting from an arbitrary day).

    $end   = new Date::Business(); # today
    # 10 business days ago
    $start = new Date::Business(DATE => $end, OFFSET => -10); 

    while (!$start->gt($end)) {
      compute_something($start);
      $start->nextb();
    }

# HOLIDAYS

Optionally, a reference to a function that counts the number of
holidays in a given date range can be passed. Business date addition,
subtraction, and difference functions will consider holidays.

Sample holiday function:

    # MUST BE NON-WEEKEND HOLIDAYS !!!
    sub holiday($$) {
       my($start, $end) = @_;
       
       my($numHolidays) = 0;
       my($holiday, @holidays);
       
       push @holidays, '19981225'; # Christmas
       push @holidays, '19990101'; $ New Year's
       
       foreach $holiday (@holidays) {
           $numHolidays++ if ($start le $holiday && $end ge $holiday);
       }
       return $numHolidays;
    }

Example using the holiday function:

    # 10 business days after 21 DEC 1998, where
    # 25 DEC 1998 and 01 JAN 1999 are holidays
    #
    $d = new Date::Business(DATE    => '19981221',
                            OFFSET  => 10,
                            HOLIDAY => \&holiday);

    print $d->image."\n"; # prints 19990106

# The diffb() function explained

The difference between two business days is relatively straightforward
when the operands are business days. The difference (in business days)
between two days when one or both of those days is a weekend or
holiday is ambiguous. The 'next' and 'prev' parameters are used to
resolve the ambiguity.

The first parameter to the diffb function is the other date. The
second parameter indicates that 'self' is to be treated as the
previous or next business date if it is not a business date. The third
parameter is similar to the second parameter but applies to the
'other' date. The default behavior is treat both dates as if the
'prev' option was set.

For example:

    $d = new Date::Business(DATE => '19991225'); # saturday
    $x = new Date::Business(DATE => '19991225'); # saturday
    print $d->image;                     # prints 19991225
    print $d->diffb($x);                 # prints  0
    print $d->diffb($x, 'prev', 'next'); # prints -1
    print $d->diffb($x, 'next', 'prev'); # prints  1
    print $d->diffb($x, 'next', 'next'); # prints  0

# CAVEATS

Business dates may be initialized with values in the range of
'19700101' through '20380119'. The range of valid results are
'19011213' through '20380119'.

Computations on dates that exceed the maximum value will wrap
around. (i.e. the day after '20380119' is '19011214'). Computations
that exceed the minimum value will result in the minimum
value. (i.e. the day before '19011213' is '19011213')
