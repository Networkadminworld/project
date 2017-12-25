InquirlyApp.directive('donutChart', function ($parse) {

    var directiveDefinitionObject = {

        restrict: 'E',

        replace: false,

        scope: {data: '=chartData'},
        link: function (scope, element, attrs) {
            var parentNode = d3.select(element[0]).node().parentNode;

            var widthBeforeParse = getComputedStyle(parentNode).width;
            var width= widthBeforeParse == "auto" ? parseInt("240") : parseInt(widthBeforeParse);

            var max_width=300;
            if(width>max_width)
            {
                width=max_width;
            }

            var otr_radius =parseInt(width/3);

            var height= parseInt(otr_radius*2);

            var inr_radius = parseInt(otr_radius-(otr_radius/4));

            var tx = (otr_radius+(otr_radius/2));

            var canvas = d3.select(element[0]).append("svg")
                .attr("width", width)
                .attr("height",height);


            scope.render=function(data) {

                if( typeof(scope.data.values) == "undefined" || scope.data.values.length==0)
                {
                    return;
                }
                canvas.selectAll('g.arc').remove();
                canvas.selectAll('text').remove();

                var group  = canvas.append("g")
                    .attr("transform","translate("+tx+","+otr_radius+")");


                var arc = d3.svg.arc()
                    .innerRadius(inr_radius)
                    .outerRadius(otr_radius);



                var pie = d3.layout.pie()
                    .value(function(d) { return  d.reach;});

                var arcs = group.selectAll(".arc")
                    .data(pie(scope.data.values))
                    .enter()
                    .append("g")
                    .attr("class","arc");

                arcs.append("path")
                    .attr("d",arc)
                    .style("fill",function(d,i){ return d.data.color;})
                    .attr('stroke', '#fff')
                    .attr('stroke-width', '2')
                    .attr('cursor','pointer')
                    .on('mouseover',function(d){
                        var scrlx = Math.abs(window.scrollX);
                        var scrly = Math.abs(window.scrollY);
                        var parentNode = d3.select(element[0]).node().parentNode;
                        var parentTop=parentNode.getBoundingClientRect().top;
                        var parentLeft=parentNode.getBoundingClientRect().left;
                        d3.select(".donut-info")
                            .style("left",(d3.event.pageX-parentLeft-scrlx)+ "px")
                            .style("top", (d3.event.pageY-parentTop-scrly)+ "px")
                            .style("opacity", 1)
                            .select(".reach")
                            .text(d.data.label+" : "+d.data.reach);
                    })
                    .on("mouseout", function(d) {
                        d3.select(".donut-info")
                            .style("opacity", 0);
                    });

                var total = d3.sum(scope.data.values, function(d) { return d.reach});
                var donut_label = scope.data.donut_label;

                group.append("text")
                    .attr("dy", "0em")
                    .style("text-anchor", "middle")
                    .attr("class", "inside")
                    .attr("font-weight","bold")
                    .attr("class","fnt-lg")
                    .text(total);

                group.append("text")
                    .attr("dy", "1.5em")
                    .style("text-anchor", "middle")
                    .attr("class", "inside fnt-xs")
                    .attr("fill", "#9B9B9B")
                    .text(donut_label);
            };

            scope.$watch('data', function(){
                scope.render(scope.data);
            }, true);

        }
    };
    return directiveDefinitionObject;
});
