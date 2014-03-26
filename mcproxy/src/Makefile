OBJECTS = main.o \
		hamcast_logging.o \
		mc_socket.o \
		addr_storage.o \
		mroute_socket.o \
		if_prop.o \
		reverse_path_filter.o \
		proxy.o \
		sender.o \
		receiver.o \
		mld_receiver.o \
		igmp_receiver.o \
		mld_sender.o \
		igmp_sender.o \
		proxy_instance.o \
		routing.o \
		worker.o \
		timing.o \
		check_if.o \
		check_kernel.o \
		membership_db.o \
		querier.o \
		timers_values.o \
		interfaces.o \
		def.o \
		simple_mc_proxy_routing.o \
		simple_routing_data.o \
		scanner.o \
		token.o \
		configuration.o \
		parser.o \
		interface.o

TARGET = mcproxy

####### Implicit rules

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o "$@" "$<"

####### Build rules

all: $(TARGET)

$(TARGET): $(OBJECTS)  
	$(CXX) $(LFLAGS) -o $(TARGET) $(OBJECTS) $(OBJCOMP) $(LIBS)

clean:
	rm -f $(OBJECTS) $(TARGET)

####### Compile

main.o: src/main.cpp include/hamcast_logging.h \
		include/utils/if_prop.hpp \
		include/utils/mc_socket.hpp \
		include/utils/addr_storage.hpp \
		include/utils/mroute_socket.hpp \
		include/proxy/proxy.hpp \
		include/proxy/timing.hpp \
		include/proxy/message_format.hpp \
		include/proxy/def.hpp \
		include/proxy/interfaces.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp \
		include/proxy/check_if.hpp \
		include/proxy/membership_db.hpp \
		include/proxy/querier.hpp \
		include/proxy/proxy_instance.hpp \
		include/proxy/worker.hpp \
		include/proxy/message_queue.hpp \
		include/proxy/simple_mc_proxy_routing.hpp \
		include/proxy/routing_management.hpp \
		include/proxy/simple_routing_data.hpp \
		include/proxy/igmp_sender.hpp \
		include/proxy/sender.hpp \
		include/parser/configuration.hpp \
		include/parser/token.hpp \
		include/tester/tester.hpp \
		include/tester/config_map.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o main.o src/main.cpp

hamcast_logging.o: src/hamcast_logging.cpp include/hamcast_logging.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o hamcast_logging.o src/hamcast_logging.cpp

mc_socket.o: src/utils/mc_socket.cpp include/hamcast_logging.h \
		include/utils/mc_socket.hpp \
		include/utils/addr_storage.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o mc_socket.o src/utils/mc_socket.cpp

addr_storage.o: src/utils/addr_storage.cpp include/hamcast_logging.h \
		include/utils/addr_storage.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o addr_storage.o src/utils/addr_storage.cpp

mroute_socket.o: src/utils/mroute_socket.cpp include/hamcast_logging.h \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/utils/addr_storage.hpp \
		include/utils/extended_mld_defines.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o mroute_socket.o src/utils/mroute_socket.cpp

if_prop.o: src/utils/if_prop.cpp include/hamcast_logging.h \
		include/utils/if_prop.hpp \
		include/utils/addr_storage.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o if_prop.o src/utils/if_prop.cpp

reverse_path_filter.o: src/utils/reverse_path_filter.cpp include/utils/reverse_path_filter.hpp \
		include/hamcast_logging.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o reverse_path_filter.o src/utils/reverse_path_filter.cpp

proxy.o: src/proxy/proxy.cpp include/hamcast_logging.h \
		include/proxy/proxy.hpp \
		include/proxy/check_kernel.hpp \
		include/proxy/timing.hpp \
		include/proxy/message_format.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp \
		include/proxy/proxy_instance.hpp \
		include/proxy/worker.hpp \
		include/proxy/message_queue.hpp \
		include/proxy/querier.hpp \
		include/proxy/membership_db.hpp \
		include/parser/configuration.hpp \
		include/parser/token.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o proxy.o src/proxy/proxy.cpp

sender.o: src/proxy/sender.cpp include/hamcast_logging.h \
		include/proxy/sender.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/message_format.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o sender.o src/proxy/sender.cpp

receiver.o: src/proxy/receiver.cpp include/hamcast_logging.h \
		include/proxy/receiver.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/message_format.hpp \
		include/proxy/def.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o receiver.o src/proxy/receiver.cpp

mld_receiver.o: src/proxy/mld_receiver.cpp include/hamcast_logging.h \
		include/proxy/mld_receiver.hpp \
		include/proxy/receiver.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/message_format.hpp \
		include/proxy/def.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp \
		include/proxy/proxy_instance.hpp \
		include/proxy/worker.hpp \
		include/proxy/message_queue.hpp \
		include/proxy/querier.hpp \
		include/proxy/membership_db.hpp \
		include/utils/extended_mld_defines.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o mld_receiver.o src/proxy/mld_receiver.cpp

igmp_receiver.o: src/proxy/igmp_receiver.cpp include/hamcast_logging.h \
		include/proxy/igmp_receiver.hpp \
		include/proxy/receiver.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/message_format.hpp \
		include/proxy/def.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp \
		include/proxy/proxy_instance.hpp \
		include/proxy/worker.hpp \
		include/proxy/message_queue.hpp \
		include/proxy/querier.hpp \
		include/proxy/membership_db.hpp \
		include/utils/extended_igmp_defines.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o igmp_receiver.o src/proxy/igmp_receiver.cpp

mld_sender.o: src/proxy/mld_sender.cpp include/hamcast_logging.h \
		include/proxy/mld_sender.hpp \
		include/proxy/sender.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/message_format.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp \
		include/utils/extended_mld_defines.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o mld_sender.o src/proxy/mld_sender.cpp

igmp_sender.o: src/proxy/igmp_sender.cpp include/hamcast_logging.h \
		include/proxy/igmp_sender.hpp \
		include/proxy/sender.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/message_format.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp \
		include/utils/extended_igmp_defines.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o igmp_sender.o src/proxy/igmp_sender.cpp

proxy_instance.o: src/proxy/proxy_instance.cpp include/hamcast_logging.h \
		include/proxy/proxy_instance.hpp \
		include/proxy/worker.hpp \
		include/proxy/message_queue.hpp \
		include/proxy/message_format.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp \
		include/proxy/querier.hpp \
		include/proxy/membership_db.hpp \
		include/proxy/receiver.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/proxy/igmp_receiver.hpp \
		include/proxy/mld_receiver.hpp \
		include/proxy/sender.hpp \
		include/proxy/igmp_sender.hpp \
		include/proxy/mld_sender.hpp \
		include/proxy/routing.hpp \
		include/proxy/timing.hpp \
		include/proxy/routing_management.hpp \
		include/proxy/simple_mc_proxy_routing.hpp \
		include/proxy/simple_routing_data.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o proxy_instance.o src/proxy/proxy_instance.cpp

routing.o: src/proxy/routing.cpp include/hamcast_logging.h \
		include/proxy/routing.hpp \
		include/utils/if_prop.hpp \
		include/proxy/interfaces.hpp \
		include/utils/reverse_path_filter.hpp \
		include/utils/addr_storage.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o routing.o src/proxy/routing.cpp

worker.o: src/proxy/worker.cpp include/hamcast_logging.h \
		include/proxy/worker.hpp \
		include/proxy/message_queue.hpp \
		include/proxy/message_format.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o worker.o src/proxy/worker.cpp

timing.o: src/proxy/timing.cpp include/hamcast_logging.h \
		include/proxy/timing.hpp \
		include/proxy/message_format.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp \
		include/proxy/worker.hpp \
		include/proxy/message_queue.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o timing.o src/proxy/timing.cpp

check_if.o: src/proxy/check_if.cpp include/hamcast_logging.h \
		include/proxy/check_if.hpp \
		include/utils/if_prop.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o check_if.o src/proxy/check_if.cpp

check_kernel.o: src/proxy/check_kernel.cpp include/hamcast_logging.h \
		include/proxy/check_kernel.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/utils/addr_storage.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o check_kernel.o src/proxy/check_kernel.cpp

membership_db.o: src/proxy/membership_db.cpp include/proxy/membership_db.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/message_format.hpp \
		include/hamcast_logging.h \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o membership_db.o src/proxy/membership_db.cpp

querier.o: src/proxy/querier.cpp include/hamcast_logging.h \
		include/proxy/querier.hpp \
		include/proxy/membership_db.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/message_format.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp \
		include/proxy/timing.hpp \
		include/proxy/sender.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/proxy/igmp_sender.hpp \
		include/proxy/mld_sender.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o querier.o src/proxy/querier.cpp

timers_values.o: src/proxy/timers_values.cpp include/proxy/timers_values.hpp \
		include/hamcast_logging.h \
		include/proxy/membership_db.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/message_format.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/parser/interface.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o timers_values.o src/proxy/timers_values.cpp

interfaces.o: src/proxy/interfaces.cpp include/hamcast_logging.h \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/utils/addr_storage.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o interfaces.o src/proxy/interfaces.cpp

def.o: src/proxy/def.cpp include/proxy/def.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o def.o src/proxy/def.cpp

simple_mc_proxy_routing.o: src/proxy/simple_mc_proxy_routing.cpp include/hamcast_logging.h \
		include/proxy/simple_mc_proxy_routing.hpp \
		include/proxy/routing_management.hpp \
		include/proxy/def.hpp \
		include/proxy/simple_routing_data.hpp \
		include/parser/interface.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/proxy_instance.hpp \
		include/proxy/worker.hpp \
		include/proxy/message_queue.hpp \
		include/proxy/message_format.hpp \
		include/proxy/timers_values.hpp \
		include/proxy/querier.hpp \
		include/proxy/membership_db.hpp \
		include/proxy/routing.hpp \
		include/proxy/sender.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp \
		include/proxy/timing.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o simple_mc_proxy_routing.o src/proxy/simple_mc_proxy_routing.cpp

simple_routing_data.o: src/proxy/simple_routing_data.cpp include/hamcast_logging.h \
		include/proxy/simple_routing_data.hpp \
		include/proxy/def.hpp \
		include/proxy/message_format.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/proxy/timers_values.hpp \
		include/parser/interface.hpp \
		include/utils/mroute_socket.hpp \
		include/utils/mc_socket.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o simple_routing_data.o src/proxy/simple_routing_data.cpp

scanner.o: src/parser/scanner.cpp include/hamcast_logging.h \
		include/parser/scanner.hpp \
		include/parser/token.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o scanner.o src/parser/scanner.cpp

token.o: src/parser/token.cpp include/hamcast_logging.h \
		include/parser/token.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o token.o src/parser/token.cpp

configuration.o: src/parser/configuration.cpp include/hamcast_logging.h \
		include/parser/configuration.hpp \
		include/parser/token.hpp \
		include/parser/interface.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp \
		include/parser/parser.hpp \
		include/parser/scanner.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o configuration.o src/parser/configuration.cpp

parser.o: src/parser/parser.cpp include/hamcast_logging.h \
		include/parser/parser.hpp \
		include/parser/scanner.hpp \
		include/proxy/def.hpp \
		include/parser/token.hpp \
		include/parser/interface.hpp \
		include/utils/addr_storage.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o parser.o src/parser/parser.cpp

interface.o: src/parser/interface.cpp include/hamcast_logging.h \
		include/parser/interface.hpp \
		include/utils/addr_storage.hpp \
		include/proxy/def.hpp \
		include/proxy/interfaces.hpp \
		include/utils/if_prop.hpp \
		include/utils/reverse_path_filter.hpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o interface.o src/parser/interface.cpp
