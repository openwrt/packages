/*******************************************************************************
 * File name : xs2184.c
 * Date : 2021.12.29 Create
 * Versions : v1.0
 * Author :	ChenMing <ccai93296@gmail.com>
 * explain : For read the state of each port,
 *           and realize the switch control of a single port
 *******************************************************************************/
#include "xs2184.h"

#define MAX_CHIPS 2
#define MAX_PORTS 8
#define MAX_AVERAGE 15
#define MAX_AVERAGE_UB 300
#define MAX_AVERAGE_LB MAX_AVERAGE

#define PERME (S_IRWXU | S_IRGRP | S_IROTH)
#define RECORD_FILE "/tmp/xs2184_record"
#define RECORD_BUF_FILE "/tmp/xs2184_tmp"
#define RECORD_DAY_FILE "/tmp/xs2184_record_day"
#define CONFIG_FN "xs2184"

#define foreach_port(i) for(i=1; i<MAX_PORTS+1; i++)

static int xs_i2c_addrs[MAX_CHIPS] = {
	XS2184_1_IIC_ADDR,
	XS2184_2_IIC_ADDR,
};

static int xs_port_to_i2c[MAX_PORTS + 1] = {
	-1, 0, 0, 0, 0, 1, 1, 1, 1,
    };

typedef struct {
	float* watts;
	u8 watch_counter;
	u8 rollback;
	u8 mark_has_pd;

	float* watts_r;
	u8 watch_counter_r;
	float ave_watts_r;
	float ave_watts_day_r;
} port_watt_t;

static port_watt_t g_pwatts[MAX_PORTS + 1];

typedef struct {
	uint32_t ts;
	float pwr[MAX_PORTS + 1];
} data_file;

#define MONITOR_INTERVAL_UB         100000
#define MONITOR_INTERVAL_LB         1000
static uint32_t statistic_inteval = MONITOR_INTERVAL_LB; //ms
static uint32_t max_average_watts = MAX_AVERAGE;

#define RECORD_TIME_UB              1080
#define RECORD_TIME_LB              1
static uint32_t record_times = RECORD_TIME_UB;
static uint32_t max_lines_file2 = 56; // file 2 caches data in a week
static uint32_t max_lines_file1 = RECORD_TIME_UB*2;
static uint32_t last_save_time;

static int rb_watts[MAX_PORTS + 1];
static uint32_t port_enable_flag[MAX_PORTS + 1];

#define MIN_LOAD_TRIG_mW_DEFAULT    1000
#define MIN_LOAD_TRIG_mW_UB         100000
#define MIN_LOAD_TRIG_mW_LB         0
#define RECORD_INTERVAL             10
#define RECORD_FORMAT               "%u %f %f %f %f %f %f %f %f \n"
/* 86400 seconds per week*/
#define UPDATE_FILE2_TIME           86400 //units: s

static u8 record_en = 0;
static uint32_t record_time_up = 0;

#define HZ (1000 / statistic_inteval)   // intv per second

#ifndef strrev
void strrev(unsigned char *str)
{
	int i;
	int j;
	unsigned char a;
	unsigned len = strlen((const char *)str);
	for (i = 0, j = len - 1; i < j; i++, j--)
	{
		a = str[i];
		str[i] = str[j];
		str[j] = a;
	}
}
#endif

#ifndef itoa
int itoa(int num, unsigned char* str, int len, int base)
{
	int sum = num;
	int i = 0;
	int digit;

	if (len == 0)
		return -1;
	do
	{
		digit = sum % base;
		if (digit < 0xA)
			str[i++] = '0' + digit;
		else
			str[i++] = 'A' + digit - 0xA;
		sum /= base;
	} while (sum && (i < (len - 1)));
	if (i == (len - 1) && sum)
		return -1;
	str[i] = '\0';
	strrev(str);
	return 0;
}
#endif

static int xs_port_to_i2c_addr(u8 port_num)
{
	int idx = xs_port_to_i2c[port_num];

	return xs_i2c_addrs[idx];
}

static int read_reg(u8 chip_addr, u8 reg_addr, u8 *reg_val)
{
	int file;
	char file_name[64];

	file = open_i2c_dev(BUS_NUM, file_name, sizeof(file_name), 0);
	if (file < 0)
		fprintf(stderr, "open dev error.\n");
	open_chip(file, chip_addr);

	*reg_val = i2c_smbus_read_byte_data(file, reg_addr);
	if (*reg_val < 0) {
		fprintf(stderr, "read failed\n");
		return -1;
	}

	close(file);

	return 0;
}

static int port_reg_read(u8 port_num, u8 reg_addr, u8 *reg_val)
{
	return read_reg(xs_port_to_i2c_addr(port_num), reg_addr, reg_val);
}

static int write_reg(u8 chip_addr, u8 reg_addr, u8 reg_val)
{
	int file;
	char file_name[20];

	file = open_i2c_dev(BUS_NUM, file_name, sizeof(file_name), 0);
	if (file < 0)
		fprintf(stderr, "open dev error.\n");
	open_chip(file, chip_addr);

	int res = i2c_smbus_write_byte_data(file, reg_addr, reg_val);
	if (res < 0) {
		fprintf(stderr, "write failed\n");
		return -1;
	}

	close(file);

	return 0;
}

static int port_reg_write(u8 port_num, u8 reg_addr, u8 reg_val)
{
	return write_reg(xs_port_to_i2c_addr(port_num), reg_addr, reg_val);
}

int open_chip(u8 file, u8 chip_addr)
{
	if (ioctl(file, I2C_SLAVE, chip_addr) < 0) {
		close(file);
		return -1;
	}

	return 0;
}

int chip_found( u8 chip_addr)
{
	u8 data = 0;
	u8 timeOut = 0;

	do {
		data = 0;
		read_reg(chip_addr, PSE_ID_REG, &data);
		timeOut++;
	} while((data != XS2184_ID_VAL)&&(timeOut < 5));

	if((timeOut > 4) || (data != XS2184_ID_VAL))
		return -1;
	else
		return 0;
}

float port_current(char port_num)
{
	float curr;
	uint32_t cur_msb = 0, cur_lsb = 0;

	port_reg_read(port_num, CURT_LSB(port_num), (u8*)&cur_lsb);
	port_reg_read(port_num, CURT_MSB(port_num), (u8*)&cur_msb);

	curr = ((float)(cur_msb << 8 | cur_lsb) / 1000.0) * ((float)CURRENT_PARA / 1000.0); //mA

	// fprintf(stdout, "port %u, current %u-%u, %.3f\n", port_num, cur_msb, cur_lsb, curr);
	return curr;
}

typedef int (* ps_callback_t)(u8 en, u8 port_num, float volt, float curt);

float port_voltage(char port_num)
{
	float volt;
	uint32_t vol_msb = 0, vol_lsb = 0;

	port_reg_read(port_num, VOLT_LSB(port_num), (u8*)&vol_lsb);
	port_reg_read(port_num, VOLT_MSB(port_num), (u8*)&vol_msb);

	volt = ((float)(vol_msb << 8 | vol_lsb) / 1000.0) * ((float)VOLTAGE_PARA / 1000.0); //uV - mV - V

	// fprintf(stdout, "port %u, volt %u-%u, %.3f\n", port_num, vol_lsb, vol_msb, volt);
	return volt;
}

static int save_date_file(uint32_t time, uint32_t line_bound, uint32_t time_bound, data_file *data,  char *fn) {
	uint32_t i;
	u8 port_num;
	FILE *fp;

	if(!(fp = fopen(RECORD_BUF_FILE, "w"))) {
		fprintf(stderr, "error in writing %s\n", RECORD_BUF_FILE);
		return -1;
	}

	for(i=0; i<line_bound; i++) {
		if (!data[i].ts)
			break;
		/* Data generated from the time before time_bound will be discarded */
		if (time - data[i].ts < time_bound) {
			fprintf(fp, "%u ", (uint32_t)data[i].ts);

			foreach_port(port_num)
			fprintf(fp, "%.2f ", data[i].pwr[port_num]);

			fprintf(fp, "\n");
		}
	}

	fclose(fp);

	rename(RECORD_BUF_FILE, fn);

	return 0;
}

static uint32_t read_data_file(uint32_t line_bound, data_file *date, char *fn) {
	uint32_t times = 0;
	FILE *fp;
	char buf_file_line[100];

	memset(&buf_file_line, 0, sizeof(buf_file_line));

	if(!(fp = fopen(fn, "r"))) {
		fprintf(stderr, "error in reading %s\n", fn);
		return -1;
	}

	while(fgets(buf_file_line, sizeof(buf_file_line), fp) != NULL) {
		/* Check data format and discard which does not conform to the format */
		if(sscanf(buf_file_line, RECORD_FORMAT,
		          &date[times].ts, &date[times].pwr[1], &date[times].pwr[2],
		          &date[times].pwr[3], &date[times].pwr[4], &date[times].pwr[5],
		          &date[times].pwr[6], &date[times].pwr[7], &date[times].pwr[8]) != MAX_PORTS + 1) {
			memset(&buf_file_line, 0, sizeof(buf_file_line));
			continue;
		}
		memset(&buf_file_line, 0, sizeof(buf_file_line));

		times++;
		/* If 'times' greater than 'line_bound', the oldest data is discarded firstly. */
		if(times == line_bound)
			times = 0;
	}
	fclose(fp);

	return times;
}

int port_status(ps_callback_t cb)
{
	u8 reg = 0;
	int i;
	unsigned char bs[40] = "\0";

	for(i=0; i<MAX_CHIPS; i++) {
		u8 port_num;
		int addr = xs_i2c_addrs[i];

		if(addr < 0)
			continue;

		(void)read_reg(addr, POWER_STA_REG, &reg);
		itoa(reg, bs, sizeof(bs), 2);
		if(!cb)
			fprintf(stdout, "chip on 0x%02x state b'%s'\n", addr, bs);
		for(port_num=1; port_num<=4; port_num++) {
			float volt, curt;
			u8 en = (PORT_MASK(port_num) & reg);
			u8 vp = i*4 + port_num;

			if(!en) {
				if(cb)
					cb(en, vp, 0, 0);
				continue;
			}

			volt = port_voltage(vp);    //V
			curt = port_current(vp);    //mA
			if(cb)
				cb(en, vp, volt, curt);
			else
				fprintf(stderr, "port %u volt/V %.2f curt/mA %.2f m-watts %.3f\n",
				        vp, volt, curt, volt * curt);
		}
	}

	if(record_time_up) {
		FILE *fp;
		u8 port_num;
		uint32_t now_time = time(NULL);
		uint32_t update_file1_time = record_times*10;

		record_time_up = 0;

		foreach_port(port_num)
		g_pwatts[port_num].ave_watts_day_r += g_pwatts[port_num].ave_watts_r;

		/* Append the latest data in file1 */
		if(!(fp = fopen(RECORD_FILE, "a"))) {
			fprintf(stderr, "error in writing %s\n", RECORD_FILE);
			return -1;
		}

		fprintf(fp, "%u ", now_time);
		foreach_port(port_num)
		fprintf(fp, "%.2f ", g_pwatts[port_num].ave_watts_r);
		fprintf(fp, "\n");

		fclose(fp);

		/**
		 * Every 3 hours, keeping the data of the last 3 hours in file1
		 * and calculating the total power consumption and saving it in file2.
		 */
		if(now_time - last_save_time >= update_file1_time) {
			int ret;
			uint32_t times = 0;
			float total_pwr[MAX_PORTS+1] = {0.0};
			data_file data_file1[max_lines_file1];
			data_file data_file2[max_lines_file2];

			memset(&data_file1, 0, sizeof(data_file1));
			memset(&data_file2, 0, sizeof(data_file2));

			foreach_port(port_num) {
				total_pwr[port_num] = g_pwatts[port_num].ave_watts_day_r;
				g_pwatts[port_num].ave_watts_day_r = 0.0;
			}

			ret = read_data_file(max_lines_file1, data_file1, (char *)RECORD_FILE);
			if(ret < 0) {
				return -1;
			}

			ret = save_date_file(now_time, max_lines_file1, update_file1_time, data_file1, (char *)RECORD_FILE);
			if(ret < 0) {
				return -1;
			}

			/* Read previous data in file2 */
			times = 0;
			times = read_data_file(max_lines_file2, data_file2, (char *)RECORD_DAY_FILE);
			if(times < 0) {
				return -1;
			}

			data_file2[times].ts = now_time;
			foreach_port(port_num)
			data_file2[times].pwr[port_num] = total_pwr[port_num];

			ret = save_date_file(now_time, max_lines_file2, UPDATE_FILE2_TIME, data_file2, (char *)RECORD_DAY_FILE);
			if(ret < 0) {
				return -1;
			}

			last_save_time = now_time;
		}
	}
	return 0;
}

int enable_port(char port_num)
{
	u8 reg;

	reg = CLASS_EN(port_num) | DET_EN(port_num);
	return port_reg_write(port_num, DETECT_CLASS_EN_REG, reg);
}

int disable_port(char port_num)
{
	u8 reg;

	reg = PWR_OFF(port_num);
	return port_reg_write(port_num, POWER_EN_REG, reg);
}

int port_monitor(u8 en, u8 vp, float volt, float curt)
{
	float mWatt = volt * curt;
	port_watt_t* pw = &g_pwatts[vp];
	int reboot_value = rb_watts[vp];

	pw->watts[pw->watch_counter++] = mWatt;
	if (record_en) {
		pw->watts_r[pw->watch_counter_r++] = mWatt;
		if (pw->watch_counter_r == RECORD_INTERVAL) {
			int i;
			pw->ave_watts_r = 0.0;
			record_time_up = 1;
			for (i=0; i<pw->watch_counter_r; i++)
				pw->ave_watts_r += pw->watts_r[i];
			if (pw->ave_watts_r)
				pw->ave_watts_r /= RECORD_INTERVAL;
			pw->watch_counter_r = 0;
		}
	}

	if(en) {
		int i, counter;
		float av_mWatt = 0.0;

		counter = pw->rollback ? max_average_watts : pw->watch_counter;
		for(i=0; i<counter; i++) {
			av_mWatt += pw->watts[i];
		}

		av_mWatt /= counter;
		if(av_mWatt < reboot_value && pw->rollback && pw->mark_has_pd) {
			pw->mark_has_pd = 0;
			pw->rollback = 0;
			pw->watch_counter = 0;
			fprintf(stdout, "port %u closed with avg %.3f mW, thd %d mW\n", vp, av_mWatt, reboot_value);
			disable_port(vp);
			sleep(1);
			enable_port(vp);
		} else if(av_mWatt >= reboot_value) {
			pw->mark_has_pd = 1;
			fprintf(stdout, "port %u, current %u has %0.2f mW, round avg %.3f mW, thd %d mW\n",
			        vp, counter, mWatt, av_mWatt, reboot_value);
		} else {
			/** port en, but no load, wait until one round rollback. */
			fprintf(stderr, "port %u, current %.2f mW, avg %.3f mW, thd %d mW\n", vp, mWatt, av_mWatt, reboot_value);
		}

		if(pw->watch_counter == max_average_watts)
			pw->rollback = 1;

		if(!port_enable_flag[vp]) {
			fprintf(stdout, "shut down port %u \n", vp);
			disable_port(vp);
			sleep(1);
		}
	} else {
		/* If the configuration sets the port to be open, try to open the port every 3 times. */
		if(port_enable_flag[vp] && !(pw->watch_counter % 3)) {
			pw->watch_counter = 0;
			pw->rollback = 0;
			pw->mark_has_pd = 0;
			/* power on & wait PD */
			fprintf(stdout, "port %u enable again PD detection\n", vp);
			enable_port(vp);
			sleep(1);   /* must keep it. */
		}
	}
	if(pw->watch_counter == max_average_watts)
		pw->watch_counter = 0;

	return 0;
}

static void get_record(char *fn, int bound, data_file *date) {
	FILE *fp;
	int ret;

	if(access(fn, R_OK|W_OK)) {
		if(!(fp = fopen(fn, "w"))) {
			fprintf(stderr, "error in writing %s\n", fn);
			exit(-1);
		}
		fclose(fp);
	} else {
		ret = read_data_file(bound, date, fn);
		if(ret<0) {
			fprintf(stderr, "error in reading %s\n", fn);
			exit(-1);
		}
	}
}

static int run_monitor(void)
{
	int i;

	memset(&g_pwatts, 0, sizeof(g_pwatts));
	for(i=0; i<sizeof(g_pwatts)/sizeof(g_pwatts[0]); i++) {
		float *pwts = malloc(sizeof(float) * max_average_watts);
		float *pwts_r = malloc(sizeof(float) * RECORD_INTERVAL);
		if(!pwts || !pwts_r) {
			exit(-1);
		}
		memset(pwts, 0, max_average_watts * sizeof(float));
		memset(pwts_r, 0, RECORD_INTERVAL * sizeof(float));
		g_pwatts[i].watts = pwts;
		g_pwatts[i].watts_r = pwts_r;
	}
	if(record_en) {
		u8 port_num;
		data_file data_file1[max_lines_file1];
		data_file data_file2[max_lines_file2];

		memset(&data_file1, 0, sizeof(data_file1));
		memset(&data_file2, 0, sizeof(data_file2));

		get_record(RECORD_FILE, max_lines_file1, data_file1);
		get_record(RECORD_DAY_FILE, max_lines_file2, data_file2);

		/**
		 * If file2 has data, the timestamp of the latest data in it is used as the starting point.
		 */
		if(data_file2[0].ts) {
			last_save_time = 0;

			for(i=0; i<max_lines_file2; i++) {
				if(!data_file2[i].ts)
					break;

				last_save_time = data_file2[i].ts > last_save_time ? (uint32_t)data_file2[i].ts : last_save_time;
			}

			for(i=0; i<max_lines_file1; i++) {
				if(last_save_time < data_file1[i].ts) {
					foreach_port(port_num)
					g_pwatts[port_num].ave_watts_day_r += data_file1[i].pwr[port_num];
				}
			}
		} else {
			last_save_time = time(NULL);

			for (i=0; i < max_lines_file1; i++) {
				if(!data_file1[i].ts)
					break;

				last_save_time = data_file1[i].ts < last_save_time ? (uint32_t)data_file1[i].ts : last_save_time;

				foreach_port(port_num)
				g_pwatts[port_num].ave_watts_day_r += data_file1[i].pwr[port_num];
			}
		}
	}

	while(1) {
		port_status((ps_callback_t)port_monitor);
		usleep(statistic_inteval * 1000);
		fflush(stdout);
		fflush(stderr);
	}

	return 0;
}

static void help()
{
	fprintf(stdout, "xs2184 : View port status and switch control of a single port\n" \
	        "usage: xs2184 [option] [port num | param]\n" \
	        "\toption : -c : Command for viewing port status\n" \
	        "\t         -u : Single port enabled\n" \
	        "\t         -d : Single port disabled\n" \
	        "\t         -m : monitor interval, range is %d-%d ms\n" \
	        "\t         -s : average statistiacs count with range %d-%d \n" \
	        "\t         -r : time-average power consumption threshold with range %d-%d mV\n" \
	        "\t         -t : record function switch\n" \
	        "\tport num : 1-%d Counting from left, one port at a time\n\n" \
	        "Example: Set port 3 to calculate the time-average power consumption \n" \
	        "\tevery 30 rounds (1000ms/round), and restart port 3 as time-average \n" \
	        "\tpower consumption is lower than 2000mV\n" \
	        "\txs2184 -u 3 -s 30 -r 2000 -m 1000\n", \
	        MONITOR_INTERVAL_LB, MONITOR_INTERVAL_UB, MAX_AVERAGE_LB, MAX_AVERAGE_UB, \
	        MIN_LOAD_TRIG_mW_LB, MIN_LOAD_TRIG_mW_UB, MAX_PORTS + 1);
}

static void show_config() {
	int i;
	fprintf(stdout, "----------------\n" \
	        "configuration : \n" \
	        "----------------\n" \
	        "round %d interval %d record_times %d record_en %d\n", \
	        max_average_watts, statistic_inteval, record_times, record_en);
	foreach_port(i)
	fprintf(stdout, "port: %d, thd: %d\n", i, rb_watts[i]);
}

static void config_parse_globals(struct uci_context *c, struct uci_section *s) {
	const char *cfg = NULL;

	cfg = uci_lookup_option_string(c, s, "round");
	max_average_watts = cfg ? atoi(cfg) : max_average_watts;

	cfg = uci_lookup_option_string(c, s, "interval");
	statistic_inteval = cfg ? atoi(cfg) : statistic_inteval;

	cfg = uci_lookup_option_string(c, s, "record_en");
	record_en = cfg ? atoi(cfg) : record_en;

	cfg = uci_lookup_option_string(c, s, "record_times");
	record_times = cfg ? atoi(cfg) : record_times;

	if(max_average_watts < MAX_AVERAGE_LB || max_average_watts > MAX_AVERAGE_UB)
		max_average_watts = MAX_AVERAGE;

	if(statistic_inteval < MONITOR_INTERVAL_LB || statistic_inteval > MONITOR_INTERVAL_UB)
		statistic_inteval = MONITOR_INTERVAL_LB;

	if(record_en != 0 && record_en != 1)
		record_en = 0;

	if(record_times < RECORD_TIME_LB || record_times > RECORD_TIME_UB)
		record_times = RECORD_TIME_UB;
}
static void save_item_uci(struct uci_ptr ptr, struct uci_context *ctx, \
                          struct uci_package *p, char *section, char *option, char *value) {
	ptr.package = CONFIG_FN;
	ptr.o = NULL;
	ptr.s = uci_lookup_section(ctx, p, section);
	ptr.section = section;
	ptr.option = option;
	ptr.value = value;
	uci_set(ctx, &ptr);
}

int main(int argc, char *argv[])
{
	int c, i;
	int port = 0;
	int monitor_enable = 0;
	char buf[10];
	struct uci_package *p = NULL;
	struct uci_context *ctx = NULL;
	struct uci_element *e;

	for(i=0; i<ARRAY_SIZE(xs_i2c_addrs); i++) {
		if(chip_found(xs_i2c_addrs[i]) < 0)
			xs_i2c_addrs[i] = -1;
		else
			fprintf(stderr, "found chip[%d] on 0x%02x\n", i, xs_i2c_addrs[i]);
	}

	/* read configuration from uci */
	fprintf(stdout, "Get configuration\n");

	ctx = uci_alloc_context();
	if (!ctx) {
		fprintf(stderr, "Out of memory\n");
		return -1;
	}

	uci_load(ctx, CONFIG_FN, &p);
	if (!p) {
		fprintf(stderr, "Failed to load config file\n");
		uci_free_context(ctx);
		return -1;
	}

	uci_foreach_element(&p->sections, e) {
		struct uci_section *s = uci_to_section(e);

		if (!strcmp(s->type, "globals"))
			config_parse_globals(ctx, s);

		if (!strncmp(s->type, "port", 4)) {
			const char *enable = NULL, *pwr_thd = NULL;
			int port_uci = 0;

			sscanf(s->e.name, "port%d", &port_uci);
			if (port_uci < 1 || port_uci > MAX_PORTS)
				port_uci = 1;

			enable = uci_lookup_option_string(ctx, s, "enable");

			if (!strcmp(enable, "1")) {
				port_enable_flag[port_uci] = 1;
				if (enable_port(port_uci) < 0)
					fprintf(stderr, "Failed to open port %d\n", port_uci);
				else
					usleep(500*1000);
			} else {
				port_enable_flag[port_uci] = 0;
				if (disable_port(port_uci) < 0)
					fprintf(stderr, "Failed to close port %d\n", port_uci);
				else
					usleep(500*1000);
			}
			pwr_thd = uci_lookup_option_string(ctx, s, "pwr_thd");
			rb_watts[port_uci] = pwr_thd ? atoi(pwr_thd) : MIN_LOAD_TRIG_mW_DEFAULT;
			if (rb_watts[port_uci] < MIN_LOAD_TRIG_mW_LB || rb_watts[port_uci] > MIN_LOAD_TRIG_mW_UB)
				rb_watts[port_uci] = MIN_LOAD_TRIG_mW_DEFAULT;
		}
	}

	struct uci_ptr ptr;
	ptr.p = p;

	while ((c = getopt(argc, argv, "d:u:m:cr:s:t:")) != -1) {
		switch (c) {
		case 'c':
			if (port_status(NULL) < 0)
				fprintf(stderr, "no PD on port.\n");
			break;
		case 'u':
			port = atoi(optarg);
			if (port < 1 || port > MAX_PORTS)
				goto input_err;

			enable_port(port);

			memset(&buf, 0, sizeof(buf));
			sprintf(buf, "port%d", port);
			save_item_uci(ptr, ctx, p, buf, "enable", "1");
			break;
		case 'd':
			port = atoi(optarg);
			if (port < 1 || port > MAX_PORTS)
				goto input_err;

			disable_port(port);

			memset(&buf, 0, sizeof(buf));
			sprintf(buf, "port%d", port);
			save_item_uci(ptr, ctx, p, buf, "enable", "0");
			break;
		case 'm':
			statistic_inteval = atoi(optarg);
			if (statistic_inteval < MONITOR_INTERVAL_LB || statistic_inteval > MONITOR_INTERVAL_UB)
				goto input_err;

			monitor_enable = 1;
			save_item_uci(ptr, ctx, p, "globals", "interval", optarg);
			break;
		case 's':
			max_average_watts = atoi(optarg);
			if (max_average_watts < MAX_AVERAGE_LB || max_average_watts > MAX_AVERAGE_UB)
				goto input_err;
			save_item_uci(ptr, ctx, p, "globals", "round", optarg);
			break;
		case 'r':
			if (port < 1 || port > MAX_PORTS)
				goto input_err;

			rb_watts[port] =  atoi(optarg); //units: mV
			if (rb_watts[port] < MIN_LOAD_TRIG_mW_LB || rb_watts[port] > MIN_LOAD_TRIG_mW_UB)
				goto input_err;

			memset(&buf, 0, sizeof(buf));
			sprintf(buf, "port%d", port);
			save_item_uci(ptr, ctx, p, buf, "pwr_thd", optarg);
			break;
		case 't':
			if (!strcmp(optarg, "1"))
				record_en = 1;
			else if (!strcmp(optarg, "0"))
				record_en = 0;
			else
				goto input_err;

			save_item_uci(ptr, ctx, p, "globals", "record_en", optarg);
			break;
		case '?':
		default:
			goto input_err;
		}
	}

	show_config();

	uci_save(ctx, ptr.p);
	uci_commit(ctx, &ptr.p, false);

	if (monitor_enable) {
		return run_monitor();
	}

	return 0;

input_err:
	help();
	return -1;
}
