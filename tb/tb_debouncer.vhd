library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- La entidad del Testbench siempre está vacía
entity tb_debouncer is
end tb_debouncer;

architecture behavior of tb_debouncer is

    -- 1. Declaración del Componente (Debe coincidir con tu debouncer.vhd)
    component debouncer
    port(
         clk          : in  std_logic;
         button_input : in  std_logic;
         bell1        : out std_logic;
         led_out      : out std_logic
        );
    end component;
    
    -- 2. Señales para conectar (Inputs inicializados a 0)
    signal t_clk    : std_logic := '0';
    signal t_button : std_logic := '0';
    
    -- Outputs (no necesitan valor inicial)
    signal t_bell   : std_logic;
    signal t_led    : std_logic;

    -- Constante del reloj (50 MHz -> 20 ns de periodo)
    constant clk_period : time := 20 ns;

begin

    -- 3. Instanciamos tu diseño (Unit Under Test)
    uut: debouncer PORT MAP (
          clk => t_clk,
          button_input => t_button,
          bell1 => t_bell,
          led_out => t_led
        );

    -- 4. Proceso del Reloj (Oscila indefinidamente)
    clk_process :process
    begin
        t_clk <= '0';
        wait for clk_period/2;
        t_clk <= '1';
        wait for clk_period/2;
    end process;

    -- 5. Proceso de Estímulos (Tu dedo + Ruido)
    stim_proc: process
    begin		
        -- Estado inicial: calma absoluta
        t_button <= '0';
        wait for 100 ns;	

        ------------------------------------------------------------
        -- PRUEBA 1: INTENTO DE ENCENDIDO CON RUIDO (Rebotes)
        ------------------------------------------------------------
        report "--> [T=0] Iniciando secuencia de RUIDO/REBOTES...";
        
        -- Simulamos el muelle del botón vibrando (microsegundos)
        t_button <= '1'; wait for 50 us;   -- Contacto breve
        t_button <= '0'; wait for 20 us;   -- Se suelta
        t_button <= '1'; wait for 100 us;  -- Contacto otra vez
        t_button <= '0'; wait for 50 us;   -- Se suelta
        t_button <= '1'; wait for 200 us;  -- Casi estable...
        t_button <= '0'; wait for 100 us;  -- Fallo final
        
        report "--> Ruido finalizado. El LED debe seguir APAGADO.";
        
        -- Ahora apretamos DE VERDAD (Estable)
        t_button <= '1'; 
        report "--> Pulsación ESTABLE detectada. Esperando filtro...";
        
        -- Esperamos 3ms (tu contador necesita 2ms para validarlo)
        wait for 3 ms;   
        
        report "--> El LED debería estar ENCENDIDO ahora.";

        -- Soltamos el botón
        t_button <= '0';
        
        ------------------------------------------------------------
        -- PAUSA (Usuario admirando el LED encendido)
        ------------------------------------------------------------
        wait for 2 ms;

        ------------------------------------------------------------
        -- PRUEBA 2: PULSAR PARA APAGAR (Sin ruido esta vez)
        ------------------------------------------------------------
        report "--> Iniciando segunda pulsación para APAGAR.";
        
        t_button <= '1';
        wait for 3 ms; -- Mantenemos apretado para superar el filtro
        t_button <= '0';
        
        wait for 1 ms;
        
        ------------------------------------------------------------
        -- FIN DE LA SIMULACIÓN
        ------------------------------------------------------------
        report "--> TEST COMPLETADO CON ÉXITO.";
        assert false report "Fin de la simulacion" severity failure;
        wait;
    end process;

end behavior;