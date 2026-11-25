#ifndef _XS2184_H_
#define _XS2184_H_

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stddef.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <assert.h>
#include <linux/types.h>
#include <sys/stat.h>
#include <uci.h>
#include <time.h>

/* -- i2c.h START -- */

/*
 * Data for SMBus Messages
 */
#define I2C_SMBUS_BLOCK_MAX	32	/* As specified in SMBus standard */
union i2c_smbus_data {
	__u8 byte;
	__u16 word;
	__u8 block[I2C_SMBUS_BLOCK_MAX + 2]; /* block[0] is used for length */
	/* and one more for PEC */
};

/* smbus_access read or write markers */
#define I2C_SMBUS_READ	1
#define I2C_SMBUS_WRITE	0

/* SMBus transaction types (size parameter in the above functions)
   Note: these no longer correspond to the (arbitrary) PIIX4 internal codes! */
#define I2C_SMBUS_QUICK		    0
#define I2C_SMBUS_BYTE		    1
#define I2C_SMBUS_BYTE_DATA	    2
#define I2C_SMBUS_WORD_DATA	    3
#define I2C_SMBUS_PROC_CALL	    4
#define I2C_SMBUS_BLOCK_DATA	    5
#define I2C_SMBUS_I2C_BLOCK_BROKEN  6
#define I2C_SMBUS_BLOCK_PROC_CALL   7		/* SMBus 2.0 */
#define I2C_SMBUS_I2C_BLOCK_DATA    8


/* NOTE: Slave address is 7 or 10 bits, but 10-bit addresses
 * are NOT supported! (due to code brokenness)
 */
#define I2C_SLAVE	0x0703	/* Use this slave address */
#define I2C_SLAVE_FORCE	0x0706	/* Use this slave address, even if it
				   is already in use by a driver! */
#define I2C_TENBIT	0x0704	/* 0 for 7 bit addrs, != 0 for 10 bit */

#define I2C_FUNCS	0x0705	/* Get the adapter functionality mask */

#define I2C_RDWR	0x0707	/* Combined R/W transfer (one STOP only) */

#define I2C_PEC		0x0708	/* != 0 to use PEC with SMBus */
#define I2C_SMBUS	0x0720	/* SMBus transfer */


/* This is the structure as used in the I2C_SMBUS ioctl call */
struct i2c_smbus_ioctl_data {
	__u8 read_write;
	__u8 command;
	__u32 size;
	union i2c_smbus_data *data;
};

static inline __s32 i2c_smbus_access(int file, char read_write, __u8 command,
                                     int size, union i2c_smbus_data *data)
{
	struct i2c_smbus_ioctl_data args;

	args.read_write = read_write;
	args.command = command;
	args.size = size;
	args.data = data;
	return ioctl(file,I2C_SMBUS,&args);
}


static inline __s32 i2c_smbus_read_byte_data(int file, __u8 command)
{
	union i2c_smbus_data data;
	if (i2c_smbus_access(file,I2C_SMBUS_READ,command,
	                     I2C_SMBUS_BYTE_DATA,&data))
		return -1;
	else
		return 0x0FF & data.byte;
}

static inline __s32 i2c_smbus_write_byte_data(int file, __u8 command,
        __u8 value)
{
	union i2c_smbus_data data;
	data.byte = value;
	return i2c_smbus_access(file,I2C_SMBUS_WRITE,command,
	                        I2C_SMBUS_BYTE_DATA, &data);
}

/* -- i2c.h END -- */


#define  BUS_NUM    2
#define  XS2184_1_IIC_ADDR   0x27
#define  XS2184_2_IIC_ADDR   0x2f

// Power Supply Status Register	  	R,	PGOOD4-1||PWR_EN4-1
#define  POWER_STA_REG		0x10

// Chip ID Register			R,	1101-0000
#define  PSE_ID_REG             0x1b

// Test and Calibration Enable Register	 R/W,CLASS_EN4-1||DET_EN4
#define  DETECT_CLASS_EN_REG    0x14

// Port Power Enable Register	 W，	PWR_OFF4-1||PWR_ON4-1
#define  POWER_EN_REG           0x19

#define  XS2184_ID_VAL      	0xd0

#define  PORT_CRT_LSB_COMMON 0x30
#define  PORT_CRT_MSB_COMMON 0x31
#define  PORT_VLT_LSB_COMMON 0x32
#define  PORT_VLT_MSB_COMMON 0x33

// Address 0x14 Enable Detection/Classification
// #define CLASS_EN4           ((u8)0x80)
// #define CLASS_EN3           ((u8)0x40)
// #define CLASS_EN2           ((u8)0x20)
// #define CLASS_EN1           ((u8)0x10)
// #define DET_EN4             ((u8)0x08)
// #define DET_EN3             ((u8)0x04)
// #define DET_EN2             ((u8)0x02)
// #define DET_EN1             ((u8)0x01)
// Address 0x19 Power Enable Button
// #define PWR_OFF4            ((u8)0x80)
// #define PWR_OFF3            ((u8)0x40)
// #define PWR_OFF2            ((u8)0x20)
// #define PWR_OFF1            ((u8)0x10)
// #define PWR_ON4             ((u8)0x08)
// #define PWR_ON3             ((u8)0x04)
// #define PWR_ON2             ((u8)0x02)
// #define PWR_ON1             ((u8)0x01)

/**
 * 	p	1	2	3	4	5	6	7	8
 *	b 	3	2	1	0	3	2	1	0
 */

#define PORT_TO_F(pn)		((pn + 3) % 4)
#define CLASS_EN(vp)		((u8)0x1 << (PORT_TO_F(vp) + 4))
#define DET_EN(vp)		((u8)0x1 << (PORT_TO_F(vp)))
#define PWR_OFF(vp)		((u8)0x1 << (PORT_TO_F(vp) + 4))
#define PWR_ON(vp)		((u8)0x1 << (PORT_TO_F(vp)))
#define PORT_MASK(pn)		((u8)0x1 << (pn - 1))

#define VOLT_MSB(vp)		(PORT_VLT_MSB_COMMON + 4 * ((vp - 1) % 4))
#define VOLT_LSB(vp)		(PORT_VLT_LSB_COMMON + 4 * ((vp - 1) % 4))
#define CURT_MSB(vp)		(PORT_CRT_MSB_COMMON + 4 * ((vp - 1) % 4))
#define CURT_LSB(vp)		(PORT_CRT_LSB_COMMON + 4 * ((vp - 1) % 4))

#define  CURRENT_PARA     122070	// uA
#define  VOLTAGE_PARA     5835		// mV

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(arr) (sizeof(arr)/sizeof((arr)[0]))
#endif

typedef unsigned char   u8;

int open_chip(u8 file, u8 chip_addr);
int chip_found( u8 chip_addr);
int enable_port(char port_num);
int disable_port(char port_num);

#endif /* _XS2184_H_ */
