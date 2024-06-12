# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

<% if house.errors.any? %>
    <div style="color: red">
      <h2><%= pluralize(house.errors.count, "error") %> prohibited this house from being saved:</h2>

      <ul>
        <% house.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  _form - houses


  <script>
document.addEventListener('DOMContentLoaded',() => {
  const apartmentSelect = document.getElementById('apartment_id')
  const blockSelect = document.getElementById('block_id')

  apartmentSelect.addEventListener('change', (event) => {
    const apartment_id = event.target.value
    
    if(countryId){
      blockSelect.innerHTML = '';
      const promptOption = document.createElement('option')
      promptOption.text = "Success"
      promptOption.value = ''
      blockSelect.appendChild(promptOption)
    }
  else {
    blockSelect.innerHTML = '';
      const promptOption = document.createElement('option')
      promptOption.text = "Success"
      promptOption.value = ''
      blockSelect.appendChild(promptOption)
  }
  })
})
</script>




  <div class="form-group my-3">
    <strong><%= form.label :apartment, style: "display: block"  , class:"control-label col-sm-2 p-2" %></strong>
    <%= form.text_field :apartment, :disabled => true, class:"form-control w-75 border border-dark", value: @apartment %>
    <% if @apartment!=nil %>
    <input type="button" id="btn1" onclick="ShowApartments()", value="Show" style="position:absolute;bottom:345px; left:310px", disabled:true />
    <% else %>
    <input type="button" id="btn1" onclick="ShowApartments()", value="Show" style="position:absolute;bottom:345px; left:310px" />
    <% end %>
  </div>

  <div class="form-group">
    <strong><%= form.label :block, style: "display: block"  , class:"control-label col-sm-2 p-2" %></strong>
    <%= form.text_field :block, :disabled => true, class:"form-control w-75 border border-dark", value: @block %> 
    <% if @block!=nil %>
    <input type="button" onclick="ShowBlocks()", value="Show" style="position:relative;bottom:10px; left:140px", disabled:true />
    <% else %>
    <input type="button" onclick="ShowBlocks()", value="Show" style="position:relative;bottom:10px; left:140px" />
    <% end %>
    
  </div>

  <div class="form-group">
    <strong><%= form.label :house, style: "display: block"  , class:"control-label col-sm-2 p-2" %></strong>
    <%= form.text_field :house, :disabled => true, class:"form-control w-75 border border-dark", value: @house %> 
    <% if @house!=nil %>
    <input type="button" onclick="ShowHouses()", value="Show" style="position:relative;bottom:10px; left:140px", disabled:true />
    <% else %>
    <input type="button" onclick="ShowHouses()", value="Show" style="position:relative;bottom:10px; left:140px" />
    <% end %>
  </div>


  <div id="box1" style="background-color: black; height:500px;width:500px; position:fixed; bottom:150px; border: 2px solid red; left:200px;display:none">
    <%if @apartments!=nil %>
      <% @apartments.each do |apartment| %>
        <%= link_to apartment.name, new_tenant_path(apartment: apartment.id), class:"btn btn-warning" %>
        <br/>
      <% end %>
    <% end %>
</div>

<div id="box2" style="background-color: black; height:500px;width:500px; position:fixed; bottom:150px; border: 2px solid red; left:200px;display:none">
  <%if @blocks!=nil %>
    <% @blocks.each do |block| %>
      <%= link_to block.name, new_tenant_path(apartment: @apartment_id, block: block.id), class:"btn btn-warning" %>
      <br/>
    <% end %>
  <% end %>
</div>

<div id="box3" style="background-color: black; height:500px;width:500px; position:fixed; bottom:150px; border: 2px solid red; left:200px;display:none">
  <% if @houses!=nil %> 
    <% @houses.each do |house| %>
      <% if house.tenant == nil %>
      <%= link_to house.doorno, new_tenant_path(apartment: @apartment_id, block: @block_id, house: house.id), class:"btn btn-warning" %>
      <br/>
      <% end %>
    <% end %>
  <% end %>
</div>
  <script>

    function ShowApartments() {
      var T = document.getElementById("box1")
      T.style.display = "block"
      var b = document.getElementById("btn1")
      b.disabled = true
    }

    function ShowBlocks() {
      var T = document.getElementById("box2")
      T.style.display = "block"
    }

    function ShowHouses() {
      var T = document.getElementById("box3")
      T.style.display = "block"
    }
  </script>


  <p>
          <% if house.tenant!=nil %>
            <%= link_to "Ask for Rent", new_message_path(desig:"tenant",to_id:house.tenant, type:"rent" ), method: :get, class:"btn btn-success" %>
            <%= link_to "Messages", messages_path , class:"btn btn-warning" %>
            <% if @messages_unread_count > 0 %>
              <%= @messages_unread_count %> new messages
            <% end %>
          <% end %>
        </p>


 
  <%= button_to "Logout", logout_path, :method => "delete" , data: { turbo_confirm: "Are you sure?" } , class: "btn btn-small btn-success" %>