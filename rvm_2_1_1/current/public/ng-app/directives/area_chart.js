InquirlyApp.directive('areaChart',['$parse', function($parse){
	return{
		restrict:'E',
		scope:{
				data:'=chartData'
			},
		link:function(scope, element, attrs){

			var margin = {top: 20, right: 20, bottom: 30, left: 50},
			    width = 740 - margin.left - margin.right,
			    height = 170 - margin.top - margin.bottom;

			var parseDate = d3.time.format("%d-%b-%y");

			var x = d3.time.scale()
			    .range([0, width]);

			var y = d3.scale.linear()
			    .range([height, 0]);

			var xAxis = d3.svg.axis()
			    .scale(x)
			    .orient("bottom")
			    .tickSize(10)
			    .tickFormat(d3.time.format("%d %b %y"));
			    

			var yAxis = d3.svg.axis()
			    .scale(y)
			    .orient("left");

			//for tooltip
			var tooltip = d3.select("body")
				.append("div")
				.style("position", "absolute")
				.style("z-index", "10")
				.style("visibility", "hidden")
				.attr("class","area-tool-tip");
			//svg it should be out side render it is a container or else graph will come two times	
			var svg = d3.select(element[0]).append("svg")
			    .attr("width", width + margin.left + margin.right)
			    .attr("height", height + margin.top + margin.bottom)
			  	.append("g")
			    .attr("transform", "translate("+30+"," + margin.top + ")");
			
			scope.render=function(data) {
				scope.data = data;
                if(_.isEmpty(scope.data) || scope.data.status == 'error'){
                    return;
                }

                if(_.isUndefined(scope.data) || scope.data.length == 0 || _.isNull(scope.data.chart_data)){
                    return;
                }

				scope.data.chart_data.forEach(function(d) {
					d.duration = new Date(d.duration);
				});
				
				//for line
				var valueline = d3.svg.line()
					.interpolate("linear")
				    .x(function(d) { return x(d.duration); })
				    .y(function(d) { return y(d.user_engaged); });

				//for area
				var area = d3.svg.area()
					.interpolate("linear")
				    .x(function(d) { return x(d.duration); })
				    .y0(height)
				    .y1(function(d) { return y(d.user_engaged); });

			    x.domain(d3.extent(scope.data.chart_data, function(d) { return d.duration; }));
			    y.domain([0, d3.max(scope.data.chart_data, function(d) { return d.user_engaged; })]);


			    //area
			    svg.append("path")
			    .datum(scope.data.chart_data)
			    .style("fill", "#DEF1BB")
			    .attr("d", area);

			    svg.append("path")
			    		.datum(scope.data.chart_data)
			            .attr("class", "line")
			            .attr("d", valueline)
			            .style("stroke", "#75BB29")
			            .style("stroke-width", "2")
			            .style("fill", "none");

			    svg.selectAll("dot")//dot part starts
			            .data(scope.data.chart_data)
			          .enter().append("circle")
			            .attr("r", 3.5)
			            .attr("cx", function(d) { return x(d.duration); })
			            .attr("cy", function(d) { return y(d.user_engaged); })
			            .style("stroke","#75BB29")
			            .style("stroke-width","2")
			            .style("fill","white")
			            .on("mouseover", function(d) {
			                      tooltip.transition()
			                           .duration(200)
			                           .style("opacity", .9);
			                      tooltip.html("<div style="+"color:#C5C5C5;font-size:12px;"+">USERS ENGAGED</div>"+
			                      				"<div style="+"padding-top:5px;color:white;font-size:16px;"+">"+
			                      				d["user_engaged"]+"</div>")
			                           .style("left", (d3.event.pageX + 5) + "px")
			                           .style("top", (d3.event.pageY - 28) + "px")
			                           .style("visibility","visible");
			                  })
			                  .on("mouseout", function(d) {
			                      tooltip.transition()
			                           .duration(1500)
			                           .style("opacity", 0);
			                  });

			    svg.append("g")
			    .attr("class","x area-axis")
			    .attr("transform", "translate(0," + height + ")")
			    .style("fill","#C3C4C4")
			    .style("font-family","Montserrat")
			    .style("font-size","10px")
			    .style("text-transform","uppercase")
			    .style("fill","#989899")
			    .call(xAxis);

			    svg.append("g")
			    .attr("class","y area-axis")
			    .style("display","none")
			    .call(yAxis);

			};
			scope.$watch('data', function(){
			  scope.render(scope.data);
			}, true); 
			
		}
	}
}]);
