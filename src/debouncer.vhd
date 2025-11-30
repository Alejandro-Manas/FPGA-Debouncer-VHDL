library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
	port(
		clk, button_input : in std_logic;
		bell1 : out std_logic;
		led_out :out std_logic);
end entity debouncer;

architecture comportamiento of debouncer is
   signal led_state : std_logic := '0';
   CONSTANT max_contador : integer := 100000;
   signal contador_antirrebotes : integer range 0 to max_contador; 
begin 
    process(clk)
	begin
    if clk' event and clk = '1' then
		if button_input = '1' and contador_antirrebotes < max_contador then
			contador_antirrebotes <= contador_antirrebotes + 1;
			if contador_antirrebotes = (max_contador-1) then
				led_state <= not led_state;
			end if;
		elsif button_input = '0' then 
			contador_antirrebotes <= 0;
		end if;
	end if;
	end process;
	led_out <= led_state;
	bell1 <= '1';
end architecture comportamiento;
	