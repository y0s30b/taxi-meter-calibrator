-- part 4/4: [data processing part]
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DATA_PROCESS is
    -- SW1~3의 스위치 입력을 받아 5가지 정보를 제공하는 내부 signal로 출력.
    port( RESET, CLK : in std_logic;
            SW1, SW2, SW3 : in std_logic;
            taxiCharge : out std_logic_vector(15 downto 0);
            taxiChargeCnt : out std_logic_vector(15 downto 0);
            extraCharge : out std_logic_vector(1 downto 0);
            mileageM : out std_logic_vector(12 downto 0);
            isCall : out std_logic
            isPayment : out std_logic);
end DATA_PROCESS;

architecture DATA_Behavioral of DATA_PROCESS is
    signal processState : std_logic_vector(1 downto 0);
    -- "00": 대기, "01": "시작", "10": "정지", "11": "정산" 
    signal SW1_flag, SW2_flag, SW3_flag : std_logic;
    signal insSW1, insSW2, insSW3 : std_logic;

    signal taxiCharge_reg, taxiChargeCnt_reg : std_logic_vector(15 downto 0);
    signal extraCharge_reg : std_logic_vector(1 downto 0);
    signal mileageM_reg : std_logic_vector(12 downto 0);
    signal isCall_reg, isPayment_reg : std_logic;
begin
    taxiCharge <= taxiCharge_reg;
    taxiChargeCnt <= taxiChargeCnt_reg;
    extraCharge <= extraCharge_reg;
    mileageM <= mileageM_reg;
    isCall <= isCall_reg;
    isPayment <= isPayment_reg;

    process(SW1, SW2, SW3)
    -- switch input을 각각의 instruction signal로 바꿔주는 process ...1/2
    begin
        -- 떼는 순간에 발생시키는 것이므로 active-LO로 동작하는 스위치에서는 '1'.
        if SW1 = '1' and SW1'event then
            SW1_flag <= '1';
        end if;
        if SW2 = '1' and SW2'event then
            SW2_flag <= '1';
        end if;
        if SW3 = '1' and SW3'event then
            SW3_flag <= '1';
        end if;
    end process;

    process(CLK)
    -- switch input을 각각의 instruction signal로 바꿔주는 process ...2/2
    begin
        if CLK = '0' and CLK'event then
        -- clk's falling edge에서 다음 falling edge까지 1 clock period만큼
        -- instruction signal을 보내주어야 다른 process에서 clk's rising edge일 때
        -- 제대로 처리할 수 있음.
            if SW1_flag = '1' then
                if insSW1 = '0' then 
                    insSW1 <= '1';
                elsif insSW1 = '1' then
                    insSW1 <= '0';
                    SW1_flag <= '0';
                end if;
            end if;
            if SW2_flag = '1' then
                if insSW2 = '0' then
                    insSW2 <= '1';
                elsif insSW2 = '1' then
                    insSW2 <= '0';
                    SW2_flag <= '0';
                end if;
            end if;
            if SW3_flag = '1' then
                if insSW3 = '0' then
                    insSW3 <= '1';
                elsif insSW3 = '1' then
                    insSW3 <= '0';
                    SW3_flag <= '0';
                end if;
            end if;
        end if;
    end process;

    process(RESET, CLK)
    -- SW1~3의 신호에 따라 원하는 회로 동작을 기술하는 process
    begin
        if RESET = '0' then
            processState <= "00";

            SW1_flag <= '0';
            SW2_flag <= '0';
            SW3_flag <= '0';
            
            insSW1 <= '0';
            insSW2 <= '0';
            insSw3 <= '0';
            
            taxiCharge_reg <= "0000_1011_1011_1000";    -- decimal 3000
            taxiChargeCnt_reg <= "0111_0101_0011_0000"; -- decimal 30000
            
            extraCharge_reg <= "00";
            mileageM_reg <= "0000_0000_0000";
            isCall_reg <= '0';
            isPayment_reg <= '0';

        elsif CLK = '1' and CLK'event then
            if insSW1 = '1' then
            end if;

            if insSW2 = '1' then
                -- 호출 여부 결정하는 신호.
                isCall_reg <= '1';
            end if;
            
            if insSW3 = '1' then
                -- 할증 % 결정하는 신호.
                if extraCharge_reg = "00" or extraCharge_reg = "01" then
                    extraCharge_reg <= extraCharge_reg + 1;
                elsif extraCharge_reg = "10" then
                    extraCharge_reg <= "00";
                end if;
            end if;
            
        end if;
    end process;
end DATA_Behavioral;
