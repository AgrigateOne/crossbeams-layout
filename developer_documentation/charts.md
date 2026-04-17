# Implementing Charts with crossbeams-layout

The `crossbeams-layout` gem includes a `Chart` component for rendering interactive Vega/Vega-Lite charts. This integrates with the [vega-ruby](https://github.com/ankane/vega-ruby) gem.

## JavaScript Setup Required

Before using charts, the host application must:

### 1. Include the Vega JavaScript libraries

Via CDN:

```html
<script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-lite@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>
```

Or via npm/yarn:

```bash
yarn add vega vega-lite vega-embed
```

### 2. Add the chart loader object

Add this to your application's JavaScript:

```javascript
window.crossbeamsCharts = {
  render: function(elementId, spec, options) {
    vegaEmbed('#' + elementId, spec, options).catch(console.error);
  }
};
```

### 3. Add the vega gem

Add to your Gemfile:

```ruby
gem 'vega'
```

## DSL Usage

Charts can be added to a Page or Section using `add_chart`:

### Basic usage with a Hash spec

```ruby
page.add_chart(
  {
    '$schema' => 'https://vega.github.io/schema/vega-lite/v5.json',
    'data' => { 'values' => data },
    'mark' => 'bar',
    'encoding' => {
      'x' => { 'field' => 'category', 'type' => 'nominal' },
      'y' => { 'field' => 'value', 'type' => 'quantitative' }
    }
  },
  id: 'my-chart',
  height: 400,
  caption: 'Sales Overview'
)
```

### Using vega-ruby gem (recommended)

```ruby
chart = Vega.lite
  .data(data)
  .mark(type: 'bar', tooltip: true)
  .encoding(
    x: { field: 'month', type: 'ordinal' },
    y: { field: 'revenue', type: 'quantitative' }
  )
  .width(500)
  .height(300)

page.add_chart(chart, id: 'revenue-chart')
```

## Available Options

| Option | Description |
|--------|-------------|
| `id` | DOM id for the chart container (auto-generated if not provided) |
| `height` | Chart height in pixels or CSS value (e.g., `400` or `'50vh'`) |
| `width` | Chart width in pixels or CSS value |
| `caption` | Title displayed above the chart |
| `embed_options` | Options passed to vega-embed (e.g., `{ actions: false, renderer: 'svg' }`) |

## Example: Dashboard with Multiple Charts

```ruby
page = Crossbeams::Layout::Page.build(form_object: OpenStruct.new) do |page, _config|
  page.section do |section|
    section.add_caption('Sales Dashboard')
    
    section.row do |row|
      row.column do |col|
        col.add_chart(
          Vega.lite
            .data(monthly_sales)
            .mark(type: 'line', point: true)
            .encoding(
              x: { field: 'month', type: 'temporal' },
              y: { field: 'sales', type: 'quantitative' }
            ),
          id: 'sales-trend',
          height: 300,
          caption: 'Monthly Sales Trend'
        )
      end
      
      row.column do |col|
        col.add_chart(
          Vega.lite
            .data(category_breakdown)
            .mark(type: 'arc', tooltip: true)
            .encoding(
              theta: { field: 'amount', type: 'quantitative' },
              color: { field: 'category', type: 'nominal' }
            ),
          id: 'category-pie',
          height: 300,
          caption: 'Sales by Category'
        )
      end
    end
  end
end
```

## Chart Types Available via Vega-Lite

| Chart Type | Mark |
|------------|------|
| Bar chart | `.mark('bar')` |
| Line chart | `.mark('line')` |
| Pie/donut chart | `.mark('arc')` |
| Area chart | `.mark('area')` |
| Scatter plot | `.mark('point')` |
| Heatmap | `.mark('rect')` |

See [Vega-Lite documentation](https://vega.github.io/vega-lite/docs/) for all options.

## DOM Loaded JavaScript

The chart initialization JavaScript is automatically included via `Page#render_dom_loaded_js`. Ensure your layout template wraps this in a DOMContentLoaded handler:

```erb
<% if page.includes_javascript? %>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      <%= page.render_dom_loaded_js.html_safe %>
    });
  </script>
<% end %>
```

## Common Patterns

### Bar Chart

```ruby
Vega.lite
  .data([{ city: 'A', sales: 28 }, { city: 'B', sales: 55 }])
  .mark(type: 'bar', tooltip: true)
  .encoding(
    x: { field: 'city', type: 'nominal' },
    y: { field: 'sales', type: 'quantitative' }
  )
```

### Line Chart with Points

```ruby
Vega.lite
  .data(time_series_data)
  .mark(type: 'line', point: true)
  .encoding(
    x: { field: 'date', type: 'temporal' },
    y: { field: 'value', type: 'quantitative' }
  )
```

### Pie Chart

```ruby
Vega.lite
  .data(category_data)
  .mark(type: 'arc', tooltip: true)
  .encoding(
    theta: { field: 'amount', type: 'quantitative' },
    color: { field: 'category', type: 'nominal' }
  )
```

### Grouped Bar Chart

```ruby
Vega.lite
  .data(grouped_data)
  .mark('bar')
  .encoding(
    x: { field: 'category', type: 'nominal' },
    y: { field: 'value', type: 'quantitative' },
    color: { field: 'group', type: 'nominal' },
    xOffset: { field: 'group' }
  )
```

## Disabling Chart Actions Menu

By default, Vega-Embed shows an actions menu (export, view source, etc.). To disable:

```ruby
page.add_chart(chart, id: 'clean-chart', embed_options: { actions: false })
```

## Using SVG Renderer

For better quality exports or print:

```ruby
page.add_chart(chart, id: 'svg-chart', embed_options: { renderer: 'svg' })
```
