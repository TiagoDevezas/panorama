function barChart() {
	var margin = {top: 20, right: 20, bottom: 20, left: 40},
			height = 300,
			xValue = function(d) { return d[0]; },
			yValue = function(d) { return d[1]; },
			xScale = d3.scale.ordinal(),
			yScale = d3.scale.linear(),
			yAxis = d3.svg.axis()
      							.scale(yScale)
      							.ticks(5)
      							.orient("left"),
			xAxis = d3.svg.axis()
      							.scale(xScale)
      							.orient("bottom")
      							.ticks(d3.time.day, 1)
      							.tickFormat(d3.time.format("%d %b"))
      							.tickSize(6, 0);

	function chart(selection) {
		selection.each(function(data) {

			// Set chart width equal to container's for responsive charts
    	width = parseInt(d3.select(this).style('width'), 10);

    	data = data.map(function(d, i) {
    		return [xValue.call(data, d, i), yValue.call(data, d, i)];
    	});

    	// Update the x-scale
    	xScale
    		.domain(data.map(function(d) { return d[0]; }))
    		.rangeRoundBands([0, width - margin.left - margin.right], .1);

    	// Update the y-scale
    	yScale
    		.domain([0, d3.max(data, function(d) { return d[1]; })])
    		.range([height - margin.top - margin.bottom, 0]);

    	var svg = d3.select(this).selectAll("svg").data([data]);

    	var gEnter = svg.enter().append("svg").append("g");
    	//gEnter.append("g").attr("class", "bars");
    	gEnter.append("g").attr("class", "x axis");
    	gEnter.append("g").attr("class", "y axis");

    	svg .attr("width", width)
    			.attr("height", height);

    	var g = svg.select("g")
    				.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  		var bars = g.selectAll(".bar")
    			.data(data);


  		var rects = bars.enter().append("g")
    			.attr("class", "bar").append("rect");

			rects.attr("x", function(d) { return xScale(d[0]); })
    			.attr("width", xScale.rangeBand())
    			.attr("y", function(d) { return yScale(d[1]); })
    			.attr("height", function(d) { return height - yScale(d[1]) - margin.top - margin.bottom; });

			rects.on('mouseenter', function(d) {
    				d3.select(this.parentNode)
    					.attr("fill", "red")
    					.append("text")
    					.attr("x", function(d) { return xScale(d[0]) + xScale.rangeBand() / 2; })
    					.attr("y", function(d) { return yScale(d[1]) - 5; })
    					.attr("dy", ".35em")
    					.attr("fill", "black")
    					.attr("text-anchor", "middle")
    					.text(function(d) { return d[1]; })
    			})
    			.on('mouseleave', function(d) {
    				d3.select(this.parentNode)
    					.attr("fill", "black")
    					.select("text").remove();
    			})
    			.on('click', function(d) {
    				updateChart();
    			});

    	function updateChart() {
    		var newData = data.push(['2014-10-25', 15]);
    		console.log(data);
    		g.selectAll("rect")
    			.data(newData)
    			.attr("y", function(d) { return yScale(d[1]); })
    			.attr("height", function(d) { return height - yScale(d[1]) - margin.top - margin.bottom; });
    	}

      // Update the x-axis.
      g.select(".x.axis")
          .attr("transform", "translate(0," + yScale.range()[0] + ")")
          .call(xAxis);

      // Update the y-axis.
      g.select(".y.axis")
      		.call(yAxis);

      g.select(".y.axis path")
      		.style("fill", "none")
      		.style("stroke", "black")
      		.style("stroke-width", 1);

      g.selectAll(".tick line")
      		.style("stroke", "black")
      		.style("stroke-width", 1);

      g.selectAll(".tick text")
      		.style("font-size", "11px");

		});
	}

  chart.margin = function(_) {
    if (!arguments.length) return margin;
    margin = _;
    return chart;
  };

  chart.width = function(_) {
    if (!arguments.length) return width;
    width = _;
    return chart;
  };

  chart.height = function(_) {
    if (!arguments.length) return height;
    height = _;
    return chart;
  };

  chart.x = function(_) {
    if (!arguments.length) return xValue;
    xValue = _;
    return chart;
  };

  chart.y = function(_) {
    if (!arguments.length) return yValue;
    yValue = _;
    return chart;
  };

  return chart;		

}