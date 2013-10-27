/*
 * wibo.h
 *
 *  Created on: 12.10.2013
 *      Author: dthiele
 */

#ifndef WIBO_H_
#define WIBO_H_

void wibo_init(uint8_t channel, uint16_t pan_id, uint16_t short_addr, uint64_t ieee_addr);
uint8_t wibo_available(void);
uint8_t wibo_proc(void);

#endif /* WIBO_H_ */
