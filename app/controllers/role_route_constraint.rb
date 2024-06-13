class RoleRouteConstraint
  def initialize(&block)
    @block = block || lambda { |desig| true }
  end

  def matches?(request)
    desig = request.session[:desig]
    desig.present? && @block.call(desig)
  end
end