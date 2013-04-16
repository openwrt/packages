/*
    Copyright (C) 2011 Pau Escrich <pau@dabax.net>
    Contributors Lluis Esquerda <eskerda@gmail.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

    The full GNU General Public License is included in this distribution in
    the file called "COPYING".
*/

		
/*
	Table pooler is a function to easy call XHR poller. 

		new TablePooler(5,"/cgi-bin/bmx6-info", {'status':''}, "status_table", function(st){
			var table = Array()
			table.push(st.first,st.second)
			return table
		}
	Parameters are: 
		polling_time: time between pollings
		json_url: the json url to fetch the data
		json_call: the json call
		output_table_id: the table where javascript will put the data
		callback_function: the function that will be executed each polling_time
	
	The callback_function must return an array of arrays (matrix).
	In the code st is the data obtained from the json call
*/

	function TablePooler (time, jsonurl, getparams, table_id, callback) {
		this.table = document.getElementById(table_id);
		this.callback = callback;
		this.jsonurl = jsonurl;
		this.getparams = getparams;
		this.time = time;

		this.clear = function(){
                  	/* clear all rows */
                  	while( this.table.rows.length > 1 ) this.table.deleteRow(1);
		}
		this.start = function(){
			XHR.poll(this.time, this.jsonurl, this.getparams, function(x, st){
				var data = this.callback(st);
				var content, tr, td;
				this.clear();
				for (var i = 0; i < data.length; i++){
					tr = this.table.insertRow(-1);
					tr.className = 'cbi-section-table-row cbi-rowstyle-' + ((i % 2) + 1);
						
					for (var j = 0; j < data[i].length; j++){
						td = tr.insertCell(-1);
						if (data[i][j].length == 2) {
							td.colSpan = data[i][j][1];
							content = data[i][j][0];
						}
						else content = data[i][j];
						td.innerHTML = content;
					}
				}
			}.bind(this));
		}


		this.start();
	}



