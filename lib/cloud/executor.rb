module Cloud::Executor
  def as_root
    original_user = box.user
    box.user = "root"
    result = yield
    box.user = original_user
    result
  end

  def exec(*commands)
    box.exec(*commands)
  end

  def exec_and_log(*commands)
    box.exec_and_log(*commands)
  end
end