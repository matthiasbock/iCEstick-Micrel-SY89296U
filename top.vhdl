library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

--
-- This is a demo for the UART RX module
--
--
entity top is
    port(
        -- 12 MHz clock input
        clock_12mhz      : in  std_logic;

        -- delay chip interface
        delay_setup      : out std_logic_vector(9 downto 0);
        delay_out        : out std_logic;
        delay_in         : in  std_logic;
        
        -- demo outputs
        output_undelayed : out std_logic;
        output_delayed   : out std_logic;

        -- LED outputs
        led_top          : out std_logic;
        led_left         : out std_logic;
        led_center       : out std_logic;
        led_right        : out std_logic;
        led_bottom       : out std_logic
    );
end;
 
--
-- Module implementation
--
architecture main of top is

    signal reset : std_logic := '1';

    signal clock_10khz : std_logic := '0';
    signal clock_3khz  : std_logic := '0';
    
    signal delay_output : std_logic := '0';

begin
    -- manage reset signals
    reset <= '0' after 30ns;
    
    --
    -- Clock divider: Generate slower clocks
    --
    process(clock_12mhz)

    constant counter_overflow_10khz : integer := 600; --1200;
        variable counter_10khz          : integer range 0 to (counter_overflow_10khz-1) := 0;

        constant counter_overflow_3khz  : integer := 20000; --4000
        variable counter_3khz           : integer range 0 to (counter_overflow_10khz-1) := 0;
        
    begin
        if (clock_12mhz'event and clock_12mhz = '1')
        then
            --
            -- generate 10 kHz clock
            --
            if (counter_10khz = 0)
            then
                if (clock_10khz = '0')
                then
                    clock_10khz <= '1';
                else
                    clock_10khz <= '0';
                end if;
                counter_10khz := counter_overflow_10khz - 1;
            else
                counter_10khz := counter_10khz - 1;
            end if;
            
            --
            -- generate 3 kHz clock
            --
            if (counter_3khz = 0)
            then
                if (clock_3khz = '0')
                then
                    clock_3khz <= '1';
                else
                    clock_3khz <= '0';
                end if;
                counter_3khz := counter_overflow_3khz - 1;
            else
                counter_3khz := counter_3khz - 1;
            end if;
        end if;
    end process;

    --
    -- Test: Change delay interval
    --
    process(clock_3khz)
        constant delay_overflow : integer := 1023;
        variable delay    : integer range 0 to delay_overflow := 0;
        variable count_up : boolean := true;
    begin
        if (clock_3khz'event and clock_3khz = '1')
        then
            delay_setup <= conv_std_logic_vector(delay, 10);

            if (delay = delay_overflow)
            then
                -- counter top reached => now count down
                count_up := false;
            end if;

            if (delay = 0)
            then
                -- counter bottom reached => now count up
                count_up := true;
            end if;

            -- adjust counter value according to current counting mode
            if (count_up)
            then
                delay := delay + 1;
            else
                delay := delay - 1;
            end if;
            
        end if;
    end process;

    --
    -- Test pulse pass through
    --
    process(clock_10khz)
    begin
        if (clock_10khz'event and clock_10khz = '1')
        then
            if (delay_output = '0')
            then
                delay_out <= '1';
                delay_output <= '1';
            else
                delay_out <= '0';
                delay_output <= '0';
            end if;
        end if;
    end process;
    
    -- Test 10 kHz clock
    led_top <= clock_10khz;

    -- Test output of test pulses
    led_bottom <= delay_output;

    -- Test arrival of delayed pulse
    led_center <= delay_in;

    -- compare delayed and undelayed pulses
    output_undelayed <= delay_output;
    output_delayed   <= delay_in;
end;
