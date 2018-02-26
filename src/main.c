#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "list.h"

#include "heartbeat_led.h"

void hardware_init(void);

int main(void)
{

    hardware_init();
    heartbeat_led_config();

    xTaskCreate(heartbeat_led_task, "led", configMINIMAL_STACK_SIZE,
                NULL, tskIDLE_PRIORITY + 1, NULL);

    vTaskStartScheduler();

    return 0;
}

// from: http://litreily.coding.me/freertos/stm32/2016/11/02/FreeRTOSInStm32.html
void hardware_init(void)
{

  //--------------------------- CLK INIT, HSE PLL ----------------------------
	ErrorStatus HSEStartUpStatus;
	//RCC reset
	RCC_DeInit();
	//开启外部时钟 并执行初始化
	RCC_HSEConfig(RCC_HSE_ON);
	//等待外部时钟准备好
	HSEStartUpStatus = RCC_WaitForHSEStartUp();
	//启动失败 在这里等待
	while(HSEStartUpStatus == ERROR);
	//设置内部总线时钟
	RCC_HCLKConfig(RCC_SYSCLK_Div1);
	RCC_PCLK1Config(RCC_HCLK_Div1);
	RCC_PCLK2Config(RCC_HCLK_Div1);
	//外部时钟为8M 这里倍频到72M
	RCC_PLLConfig(RCC_PLLSource_HSE_Div1, RCC_PLLMul_9);
	RCC_PLLCmd(ENABLE);
	while(RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET);
	RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK);
	while(RCC_GetSYSCLKSource() != 0x08);

	//----------------------------- CLOSE HSI ---------------------------
	//关闭内部时钟HSI
	RCC_HSICmd(DISABLE);

	//中断配置 2-level interrupt
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);

	//开总中断
	__enable_irq();
	/****************** 	OPEN GPIO CLK 	**************/
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);

}



void assert_failed(uint8_t* file, uint32_t line)
{
    for(;;){
    }
}
