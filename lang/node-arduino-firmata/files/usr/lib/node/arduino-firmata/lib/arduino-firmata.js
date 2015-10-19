(function() {
  'use strict';
  var ArduinoFirmata, SerialPort, debug, events, exports, serialport,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  events = require('eventemitter2');

  SerialPort = (serialport = require('serialport')).SerialPort;

  debug = require('debug')('arduino-firmata');

  exports = module.exports = ArduinoFirmata = (function(superClass) {
    extend(ArduinoFirmata, superClass);

    ArduinoFirmata.Status = {
      CLOSE: 0,
      OPEN: 1
    };

    ArduinoFirmata.INPUT = 0;

    ArduinoFirmata.OUTPUT = 1;

    ArduinoFirmata.ANALOG = 2;

    ArduinoFirmata.PWM = 3;

    ArduinoFirmata.SERVO = 4;

    ArduinoFirmata.SHIFT = 5;

    ArduinoFirmata.I2C = 6;

    ArduinoFirmata.LOW = 0;

    ArduinoFirmata.HIGH = 1;

    ArduinoFirmata.MAX_DATA_BYTES = 32;

    ArduinoFirmata.DIGITAL_MESSAGE = 0x90;

    ArduinoFirmata.ANALOG_MESSAGE = 0xE0;

    ArduinoFirmata.REPORT_ANALOG = 0xC0;

    ArduinoFirmata.REPORT_DIGITAL = 0xD0;

    ArduinoFirmata.SET_PIN_MODE = 0xF4;

    ArduinoFirmata.REPORT_VERSION = 0xF9;

    ArduinoFirmata.SYSTEM_RESET = 0xFF;

    ArduinoFirmata.START_SYSEX = 0xF0;

    ArduinoFirmata.END_SYSEX = 0xF7;

    ArduinoFirmata.list = function(callback) {
      return serialport.list(function(err, ports) {
        var devices, j, len, port;
        if (err) {
          return callback(err);
        }
        devices = [];
        for (j = 0, len = ports.length; j < len; j++) {
          port = ports[j];
          if (/usb|acm|com\d+/i.test(port.comName)) {
            devices.push(port.comName);
          }
        }
        return callback(null, devices);
      });
    };

    function ArduinoFirmata() {
      this.status = ArduinoFirmata.Status.CLOSE;
      this.wait_for_data = 0;
      this.execute_multi_byte_command = 0;
      this.multi_byte_channel = 0;
      this.stored_input_data = [];
      this.parsing_sysex = false;
      this.sysex_bytes_read = 0;
      this.digital_output_data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      this.digital_input_data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      this.analog_input_data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      this.boardVersion = null;
    }

    ArduinoFirmata.prototype.isOldArduinoDevice = function() {
      return /usbserial|USB/.test(this.serialport_name);
    };

    ArduinoFirmata.prototype.connect = function(serialport_name, opts) {
      this.serialport_name = serialport_name;
      if (opts == null) {
        opts = {
          baudrate: 57600
        };
      }
      opts.parser = serialport.parsers.raw;
      if (!this.serialport_name) {
        ArduinoFirmata.list((function(_this) {
          return function(err, devices) {
            return _this.connect(devices[0], opts);
          };
        })(this));
        return this;
      }
      this.once('boardReady', function() {
        var io_init_wait;
        debug('boardReady');
        io_init_wait = this.isOldArduinoDevice() ? (debug("old arduino device found " + this.serialport_name), 3000) : (debug("new arduino device found " + this.serialport_name), 100);
        debug("wait " + io_init_wait + "(msec)");
        return setTimeout((function(_this) {
          return function() {
            var i, j, k;
            for (i = j = 0; j < 6; i = ++j) {
              _this.write([ArduinoFirmata.REPORT_ANALOG | i, 1]);
            }
            for (i = k = 0; k < 2; i = ++k) {
              _this.write([ArduinoFirmata.REPORT_DIGITAL | i, 1]);
            }
            debug('init IO ports');
            return _this.emit('connect');
          };
        })(this), io_init_wait);
      });
      this.serialport = new SerialPort(this.serialport_name, opts);
      this.serialport.once('open', (function(_this) {
        return function() {
          var cid;
          cid = setInterval(function() {
            debug('request REPORT_VERSION');
            return _this.write([ArduinoFirmata.REPORT_VERSION]);
          }, 500);
          _this.once('boardVersion', function(version) {
            clearInterval(cid);
            _this.status = ArduinoFirmata.Status.OPEN;
            return _this.emit('boardReady');
          });
          return _this.serialport.on('data', function(data) {
            var byte, j, len, results;
            results = [];
            for (j = 0, len = data.length; j < len; j++) {
              byte = data[j];
              results.push(_this.process_input(byte));
            }
            return results;
          });
        };
      })(this));
      return this;
    };

    ArduinoFirmata.prototype.isOpen = function() {
      return this.status === ArduinoFirmata.Status.OPEN;
    };

    ArduinoFirmata.prototype.close = function(callback) {
      this.status = ArduinoFirmata.Status.CLOSE;
      return this.serialport.close(callback);
    };

    ArduinoFirmata.prototype.reset = function(callback) {
      return this.write([ArduinoFirmata.SYSTEM_RESET], callback);
    };

    ArduinoFirmata.prototype.write = function(bytes, callback) {
      return this.serialport.write(bytes, callback);
    };

    ArduinoFirmata.prototype.sysex = function(command, data, callback) {
      var write_data;
      if (data == null) {
        data = [];
      }
      data = data.map(function(i) {
        return i & 0x7f;
      });
      write_data = [ArduinoFirmata.START_SYSEX, command].concat(data, [ArduinoFirmata.END_SYSEX]);
      return this.write(write_data, callback);
    };

    ArduinoFirmata.prototype.pinMode = function(pin, mode, callback) {
      switch (mode) {
        case true:
          mode = ArduinoFirmata.OUTPUT;
          break;
        case false:
          mode = ArduinoFirmata.INPUT;
      }
      return this.write([ArduinoFirmata.SET_PIN_MODE, pin, mode], callback);
    };

    ArduinoFirmata.prototype.digitalWrite = function(pin, value, callback) {
      var port_num;
      this.pinMode(pin, ArduinoFirmata.OUTPUT);
      port_num = (pin >>> 3) & 0x0F;
      if (value === 0 || value === false) {
        this.digital_output_data[port_num] &= ~(1 << (pin & 0x07));
      } else {
        this.digital_output_data[port_num] |= 1 << (pin & 0x07);
      }
      return this.write([ArduinoFirmata.DIGITAL_MESSAGE | port_num, this.digital_output_data[port_num] & 0x7F, this.digital_output_data[port_num] >>> 7], callback);
    };

    ArduinoFirmata.prototype.analogWrite = function(pin, value, callback) {
      value = Math.floor(value);
      this.pinMode(pin, ArduinoFirmata.PWM);
      return this.write([ArduinoFirmata.ANALOG_MESSAGE | (pin & 0x0F), value & 0x7F, value >>> 7], callback);
    };

    ArduinoFirmata.prototype.servoWrite = function(pin, angle, callback) {
      this.pinMode(pin, ArduinoFirmata.SERVO);
      return this.write([ArduinoFirmata.ANALOG_MESSAGE | (pin & 0x0F), angle & 0x7F, angle >>> 7], callback);
    };

    ArduinoFirmata.prototype.digitalRead = function(pin) {
      return ((this.digital_input_data[pin >>> 3] >>> (pin & 0x07)) & 0x01) > 0;
    };

    ArduinoFirmata.prototype.analogRead = function(pin) {
      return this.analog_input_data[pin];
    };

    ArduinoFirmata.prototype.process_input = function(input_data) {
      var analog_value, command, diff, i, j, old_analog_value, results, stat, sysex_command, sysex_data;
      if (this.parsing_sysex) {
        if (input_data === ArduinoFirmata.END_SYSEX) {
          this.parsing_sysex = false;
          sysex_command = this.stored_input_data[0];
          sysex_data = this.stored_input_data.slice(1, this.sysex_bytes_read);
          return this.emit('sysex', {
            command: sysex_command,
            data: sysex_data
          });
        } else {
          this.stored_input_data[this.sysex_bytes_read] = input_data;
          return this.sysex_bytes_read += 1;
        }
      } else if (this.wait_for_data > 0 && input_data < 128) {
        this.wait_for_data -= 1;
        this.stored_input_data[this.wait_for_data] = input_data;
        if (this.execute_multi_byte_command !== 0 && this.wait_for_data === 0) {
          switch (this.execute_multi_byte_command) {
            case ArduinoFirmata.DIGITAL_MESSAGE:
              input_data = (this.stored_input_data[0] << 7) + this.stored_input_data[1];
              diff = this.digital_input_data[this.multi_byte_channel] ^ input_data;
              this.digital_input_data[this.multi_byte_channel] = input_data;
              if (this.listeners('digitalChange').length > 0) {
                results = [];
                for (i = j = 0; j <= 13; i = ++j) {
                  if (((0x01 << i) & diff) > 0) {
                    stat = (input_data & diff) > 0;
                    results.push(this.emit('digitalChange', {
                      pin: i + this.multi_byte_channel * 8,
                      value: stat,
                      old_value: !stat
                    }));
                  } else {
                    results.push(void 0);
                  }
                }
                return results;
              }
              break;
            case ArduinoFirmata.ANALOG_MESSAGE:
              analog_value = (this.stored_input_data[0] << 7) + this.stored_input_data[1];
              old_analog_value = this.analogRead(this.multi_byte_channel);
              this.analog_input_data[this.multi_byte_channel] = analog_value;
              if (old_analog_value !== analog_value) {
                return this.emit('analogChange', {
                  pin: this.multi_byte_channel,
                  value: analog_value,
                  old_value: old_analog_value
                });
              }
              break;
            case ArduinoFirmata.REPORT_VERSION:
              this.boardVersion = this.stored_input_data[1] + "." + this.stored_input_data[0];
              return this.emit('boardVersion', this.boardVersion);
          }
        }
      } else {
        if (input_data < 0xF0) {
          command = input_data & 0xF0;
          this.multi_byte_channel = input_data & 0x0F;
        } else {
          command = input_data;
        }
        if (command === ArduinoFirmata.START_SYSEX) {
          this.parsing_sysex = true;
          return this.sysex_bytes_read = 0;
        } else if (command === ArduinoFirmata.DIGITAL_MESSAGE || command === ArduinoFirmata.ANALOG_MESSAGE || command === ArduinoFirmata.REPORT_VERSION) {
          this.wait_for_data = 2;
          return this.execute_multi_byte_command = command;
        }
      }
    };

    return ArduinoFirmata;

  })(events.EventEmitter2);

}).call(this);
