InquirlyApp.directive('barGraph',function(){
    return{
       	restrict:'E',
       	replace:false,
       	scope:{
       		data:'=graphData'
   	    },
   	    link:function(scope,elmement,attrs){
           
            var margin  = {top: 70, right: 50, bottom: 50, left: 15};
            var width   = 345 - margin.left - margin.right;
            var height  = 334 - margin.top - margin.bottom;
            var svg = d3.select(elmement[0])
                        .append("svg")
                        .attr('width' , width + margin.left + margin.right)
                        .attr('height' , height + margin.top + margin.bottom)
                        .append("g")
                        .attr("transform","translate("+ margin.left + "," + margin.top + ")");

            //create the scales we need for graph
            var x = d3.scale.ordinal().rangeRoundBands([0, width], .11);
            var y = d3.scale.linear().range([height, 0]);

            //create the axis 

            var xAxis = d3.svg.axis()
                          .scale(x)
                          .orient("bottom");
            
            scope.render = function(data){

                if(_.isEmpty(scope.data) || scope.data.status == 'error'){
                    return;
                }

                if(_.isUndefined(scope.data) || scope.data.length == 0 || _.isNull(scope.data.chart_data)){
                    return;
                }

                //set our scale's for domains
                
                x.domain(scope.data.chart_data.map(function(d){ 
                    return d.status; 
                }));

                y.domain([0, d3.max(scope.data.chart_data, function(d){ 
                       return d.value; 
                })]);

                svg.selectAll('g.bar-chart').remove();

                //render the X axis 
                svg.append("g")
                    .attr("class", " x bar-chart")
                    .attr("transform","translate(0 ," + height + ")")
                    .call(xAxis);
                svg.selectAll(' x.bar-chart').remove();

                var bars = svg.selectAll(".bar").data(scope.data.chart_data);
                    bars.enter()
                        .append("rect")
                        .attr("class","bar")
                        .attr("x", function(d){ 
                            return x(d.status); 
                        })
                        .attr("width", x.rangeBand())
                        .attr("y", function(d){
                            return height;
                        })
                        .attr("height",0);

                    bars.transition()
                        .duration(500)
                        .delay(50)
                        .style("fill",function(d,i){
                            return (d.color);
                        })
                        .attr('height', function(d){ 
                            return height - y(d.value); 
                        })
                        .attr("y", function(d){ 
                            return y(d.value); 
                        });

                var chart_value = svg.selectAll(".text").data(scope.data.chart_data);
                d3.select(elmement[0]).selectAll('text.y-value').remove();
                    chart_value.enter()
                               .append("text")
                               .attr("class","y-value")
                               .attr("text-anchor","middle")
                               .attr("x",function(d,i){
                                    return i * (width/scope.data.chart_data.length) + (width /scope.data.chart_data.length) / 2;
                                })
                               .attr("y", function(d,i) {
                                    return (y(d.value)-10 );

                                })

                                .style("fill","#C3C0C0")

                                .text(function(d,i){
                                    return d.value;
                                })
                    
            };
           
            scope.$watch('data',function(){
                scope.render(scope.data);
            },true);

        }
    }
});