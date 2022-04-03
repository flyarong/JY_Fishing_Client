MathExtend = {}
Deg2Rad = (3.1415926 * 2) / 360

MathExtend.ParseInt = function (val)
    return math.floor(val + 0.000001)
end

MathExtend.Pow = function (v, n)
    if (n == 1) then return v end
    local val = 1
    for i = 1, n, 1 do
        val = val * v
    end
    return val
end


MathExtend.Decimal = function (v, num)
    if (num == nil) then num = 0 end
    v = ParseInt(v * Pow(10, num))
    v = v / Pow(10, num)
    return v
end

MathExtend.SortList = function (list, order, isUp)
    isUp = isUp or false -- 默认降序
    for i = 1, #list - 1 do
        local k = i
        for j = i + 1, #list do
            if isUp then
                if (order and list[k][order] > list[j][order]) or (not order and list[k] > list[j]) then
                    k = j
                end
            else
                if (order and list[k][order] < list[j][order]) or (not order and list[k] < list[j]) then
                    k = j
                end
            end            
        end
        if k ~= i then
            list[i],list[k] = list[k],list[i]
        end
    end
    return list
end

MathExtend.SortListCom = function (list, call)
    for i = 1, #list - 1 do
        local k = i
        for j = i + 1, #list do
            if call(list[k], list[j]) then
                k = j
            end
        end
        if k ~= i then
            list[i],list[k] = list[k],list[i]
        end
    end
    return list
end

MathExtend.isTimeValidity = function (beginT, endT)
    local curT=os.time()
    if beginT and beginT >= 0 and curT < beginT then
        return false
    end
    if endT and endT >= 0 and curT > endT then
        return false
    end
    return true
end

MathExtend.RandomGroup = function (num)
    local data = {}
    for i = 1, num do
        data[#data + 1] = i
    end
    local num1 = num
    while num1 > 1 do
        local i = math.random(1, num1)
        if i ~= num1 then
            data[i],data[num1] = data[num1],data[i]
        end
        num1 = num1 - 1
    end
    return data
end

-- 高n位
MathExtend.GetGW = function (num, n)    
    local a = 0
    local s = 0
    local b = 0
    num = math.floor(tonumber(num))
    while (num > 0) do
        local d = num % 10
        num = math.floor(num/10)
        if a >= n then
            s = s + math.pow(10,n) * d
        else
            s = s + math.pow(10,a) * d
        end
        a = a + 1
        if s > math.pow(10, n) then
            s = math.floor(s/10)
        end
    end

    local tt = {g=s}
    if a < n then
        tt.w = 1
    else
        tt.w = math.pow(10,a-n)
    end
    return tt
end
MathExtend.SplitNumber = function (num, n)
    local tt
    if n < 10 then
        tt = MathExtend.GetGW(num, 2)
    else
        tt = MathExtend.GetGW(num, 3)
    end

    local a = math.floor(tt.g/n)
    local mm = {}
    local all = 0
    for i=1,n do
        if i < n then
            mm[#mm + 1] = a * tt.w
            all = all + mm[#mm]
        else
            mm[#mm + 1] = num - all
        end
    end
    return mm
end
-- 角度限制到固定区间
MathExtend.JDSwitch = function (min, max, step_num, num)
    if num >= min and num <= max then
        return num
    elseif num < min then
        if (num + step_num) >= min and (num + step_num) <= max then
            return num + step_num
        else
            return min
        end
    else
        if (num - step_num) >= min and (num - step_num) <= max then
            return num - step_num
        else
            return max
        end
    end
end
-- 素数
MathExtend.CalcSS = function (n)
    local tt = os.clock()

    local primes = {}
    local is_primes = {}
    for i = 2, n do
        is_primes[i] = 1
    end
    for i = 2, n do
        if is_primes[i] then
            primes[#primes + 1] = i
            local j = 2*i
            while(j<=n) do
                is_primes[j] = nil
                j = j + i
            end
        end
    end
    dump(#primes)
    dump(primes[#primes])
    dump(os.clock()-tt)
    return primes
end

-- 求根
MathExtend.CalcSqrt = function (n, c)
    local a = 2
    local b = 0
    local run = 1
    while (true) do
        b = n / a
        if math.abs(a - b) < c then
            a = (a + b) * 0.5
            break
        end
        run = run + 1
        a = (a + b) * 0.5
        if run >= 1000 then
            break
        end
    end
    print(run)
    print(a)
    return a
end

--切割数字 123 ——> {1,2,3}
MathExtend.SplitNumberToString = function (number,len)
    local tbl = {}
    local nn = number
    while nn > 0 do
        tbl[#tbl + 1] = nn % 10
        nn = math.floor(nn / 10)
    end
    local array = {}
    if len then
        if len > #tbl then
            for idx = len, 1, -1 do
                if idx > #tbl then
                    array[#array + 1] = 0
                else
                    array[#array + 1] = ""..tbl[idx]
                end
            end
        else
            for idx = #tbl, 1, -1 do
                array[#array + 1] = ""..tbl[idx]
            end
            print("<color=red>EEE 长度定义不合理 number = " .. number .. "  len = " .. len .. "</color>")
        end
    else
        for idx = #tbl, 1, -1 do
            array[#array + 1] = ""..tbl[idx]
        end
    end
    return array
end
