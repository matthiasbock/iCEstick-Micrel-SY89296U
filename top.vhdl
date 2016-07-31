library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_bit.all;

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

begin
    -- manage reset signals
    reset <= '0' after 30ns;

    --delay_setup <= others => '1';
    
    --
    -- Clock divider: 12 MHz -> 10 kHz
    --
    process(clock_12mhz)
        constant counter_overflow: integer := 600; --1200;
        variable tick_counter : integer range 0 to (counter_overflow-1) := 0;
    begin
        if (clock_12mhz'event and clock_12mhz = '1')
        then
            if (tick_counter = 0)
            then
                if (clock_10khz = '0')
                then
                    clock_10khz <= '1';
                else
                    clock_10khz <= '0';
                end if;
                tick_counter := counter_overflow-1;
            else
                tick_counter := tick_counter - 1;
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
            if (delay_out = '0')
            then
                delay_out <= '1';
            else
                delay_out <= '0';
            end if;
        end if;
    end process;
    
    led_top <= clock_10khz;
    led_bottom <= delay_out;
    
    --
    -- Test arrival of delayed pulse
    --
    led_center <= delay_in;
end;
