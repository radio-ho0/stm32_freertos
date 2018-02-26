#ifndef __SRC_HEARTBEAT_LED_H__
#define __SRC_HEARTBEAT_LED_H__

#include "FreeRTOS.h"
#include "stm32f10x_conf.h"

#define PORT_FAMILY (GPIOC)
#define LED_PORT    (GPIO_Pin_13)

void heartbeat_led_config(void)
{
    GPIO_InitTypeDef GPIO_InitStructure;
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);  //使能gpioc的时    
    GPIO_InitStructure.GPIO_Pin = LED_PORT;                //选择管脚PC.13作LED灯
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_2MHz;      //管脚速度为2MHZ
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;       //设置输出模式为推挽输出
    GPIO_Init(PORT_FAMILY, &GPIO_InitStructure);           //将上述设置写入到GPIOC里去
}


void heartbeat_led_task(void* pvParameters)
{
    uint8_t led_flags          = 0;
    const TickType_t frequency = 1000 / portTICK_RATE_MS;
    TickType_t last_wake_time  = xTaskGetTickCount();

    while(1){
        if(led_flags > 0){
            GPIO_SetBits(PORT_FAMILY,   LED_PORT);           //熄灭LED
            led_flags  = 0;
        }else{
            GPIO_ResetBits(PORT_FAMILY, LED_PORT);           //点亮LED
            ++led_flags;
        }
        vTaskDelayUntil(&last_wake_time, frequency);
    }
}

#endif //__SRC_HEARTBEAT_LED_H__
