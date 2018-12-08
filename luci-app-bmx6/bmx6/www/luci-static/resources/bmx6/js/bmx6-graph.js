var graph, canvas, layouter, renderer, divwait, nodes, announcements, nodesIndex, palette, localInfo;
document.addEventListener( "DOMContentLoaded", init, false);

/**
 * Returns an index of nodes by name
 */
function createNodeIndex(nodes) {
  var inode, index = {};

  for (inode in nodes)
    index[nodes[inode].name] = nodes[inode];

  return index;
}

/**
 * Updates to have announcements in nodes list
 */
function processNodeAnnouncements(nodes, announcements) {
  var iannouncement, remoteNode, announcement;
  nodesIndex = createNodeIndex(nodes);

  for(iannouncement in announcements) {
    announcement = announcements[iannouncement];
    if (announcement.remoteName == '---' ) continue;
    if (!( announcement.remoteName in nodesIndex )) {
      newNode = {
        name: announcement.remoteName,
        links: []
      };
      nodes.push(newNode);
      nodesIndex[newNode.name] = newNode;
    };

    remoteNode = nodesIndex[announcement.remoteName];
    if (!( 'announcements' in remoteNode )) remoteNode.announcements = [];
    remoteNode.announcements.push(announcement);
  };
}

function init() {
  palette = generatePalette(200);

  graph = new Graph();
  canvas = document.getElementById('canvas');
  layouter = new Graph.Layout.Spring(graph);
  renderer = new Graph.Renderer.Raphael(canvas.id, graph, canvas.offsetWidth, canvas.offsetHeight);

  divwait = document.getElementById("wait");

  XHR.get('/cgi-bin/luci/admin/network/BMX6/topology', null, function(nodesRequest, nodesData) {
    nodes = nodesData;

    XHR.get('/cgi-bin/bmx6-info?$myself&', null, function(myselfRequest, myselfData) {
      if (myselfData)
        localAnnouncements = [
          {remoteName: myselfData.myself.hostname, advNet: myselfData.myself.net4},
          {remoteName: myselfData.myself.hostname, advNet: myselfData.myself.net6}
        ];

      XHR.get('/cgi-bin/bmx6-info?$tunnels=&', null, function(tunnelsRequest, tunnelsData) {
        var iAnnouncement;

        announcements = tunnelsData.tunnels;
        for(iAnnouncement in localAnnouncements) {
          announcements.push(localAnnouncements[iAnnouncement])
        };

        processNodeAnnouncements(nodes, announcements);

        divwait.parentNode.removeChild(divwait);
        draw(nodes);
      });
    });
  });
}

function hashCode(str) {
  var hash = 0;
  if (str.length == 0) return hash;
  for (i = 0; i < str.length; i++) {
    char = str.charCodeAt(i);
    hash = ((hash<<5)-hash)+char;
    hash = hash & hash; // Convert to 32bit integer
  }
  return hash;
}

function generatePalette(size) {
  var i, arr = [];
  Raphael.getColor(); // just to remove the grey one
  for(i = 0; i < size; i++) {
    arr.push(Raphael.getColor())
  }

  return arr;
}

function getFillFromHash(hash) {
  return palette[Math.abs(hash % palette.length)];
}

function hashAnnouncementsNames(announcementsNames) {
  return hashCode(announcementsNames.sort().join('-'));
}

function getNodeAnnouncements(networkNode) {
  return networkNode.announcements;
}

function nodeRenderer(raphael, node) {
  var nodeFill, renderedNode, options;
  options = {
    'fill': 'announcements' in node.networkNode ? getFillFromHash(
      hashAnnouncementsNames(
        getNodeAnnouncements(node.networkNode).map(function(ann) {return ann.advNet;})
      )
    ) : '#bfbfbf',
    'stroke-width': 1,

  };

  renderedNode = raphael.set();

  renderedNode.push(raphael.ellipse(node.point[0], node.point[1], 30, 20).attr({"fill": options['fill'], "stroke-width": options['stroke-width']}));
  renderedNode.push(raphael.text(node.point[0], node.point[1] + 30, node.networkNode.name).attr({}));

  renderedNode.items.forEach(function(el) {
    var announcements, tooltip = raphael.set();
    tooltip.push(raphael.rect(-60, -60, 120, 60).attr({"fill": "#fec", "stroke-width": 1, r : "9px"}));

    announcements = getNodeAnnouncements(node.networkNode);
    if (announcements) {

      announcements = announcements.map(function(ann) {return ann.advNet});
      tooltip.push(raphael.text(0, -40, 'announcements\n' + announcements.join('\n')).attr({}));
    };

    el.tooltip(tooltip);
  });

  return renderedNode;
}

function genericNodeRenderer(raphael, node) {
  var renderedNode;

  renderedNode = raphael.set();

  renderedNode.push(raphael.ellipse(node.point[0], node.point[1], 30, 20).attr({"fill": '#bfbfbf', "stroke-width": 1}));
  renderedNode.push(raphael.text(node.point[0], node.point[1] + 30, node.networkNode.name).attr({}));

  return renderedNode;
}

function redraw() {
  layouter.layout();
  renderer.draw();
}

function interpolateColor(minColor,maxColor,maxDepth,depth){

  function d2h(d) {return d.toString(16);}
  function h2d(h) {return parseInt(h,16);}

  if(depth == 0){
    return minColor;
  }
  if(depth == maxDepth){
    return maxColor;
  }

  var color = "#";

  for(var i=1; i <= 6; i+=2){
    var minVal = new Number(h2d(minColor.substr(i,2)));
    var maxVal = new Number(h2d(maxColor.substr(i,2)));
    var nVal = minVal + (maxVal-minVal) * (depth/maxDepth);
    var val = d2h(Math.floor(nVal));
    while(val.length < 2){
      val = "0"+val;
    }
    color += val;
  }
  return color;
}
function draw(nodes) {
  var node, neighbourNode, seenKey, rxRate, txRate, seen, i, j, currentName, linkQuality;

  seen = { };

  for (i = 0; i < (nodes.length); i++) {
    node = nodes[i];
    graph.addNode(node.name, {
      networkNode: node,
      render: nodeRenderer
    });
  };

  for (i = 0; i < (nodes.length); i++) {
    node = nodes[i];

    if (! node.name) continue;

    currentName = node.name;

    for (j = 0; j < (node.links.length); j++) {
      neighbourNode = node.links[j];

      graph.addNode(neighbourNode.name, {render: genericNodeRenderer, networkNode: neighbourNode});

      seenKey = (node.name < neighbourNode.name) ? node.name + '|' + neighbourNode.name : neighbourNode.name + '|' + node.name;

      rxRate = neighbourNode.rxRate;
      txRate = neighbourNode.txRate;

      if (!seen[seenKey] && rxRate > 0 && txRate > 0) {
        linkQuality = ( rxRate + txRate ) / 2;

        graph.addEdge(node.name, neighbourNode.name, {
          'label': rxRate + '/' + txRate,
          'directed': false,
          'stroke': interpolateColor('FF0000','00FF00', 5, 5 * ( linkQuality - 1 )/100),
          'fill': interpolateColor('FF0000','00FF00', 5, 5 * ( linkQuality - 1 )/100),
          'label-style': { 'font-size': 8 }
        });

        seen[seenKey] = true;
      }
    }
  }

  redraw();
}
