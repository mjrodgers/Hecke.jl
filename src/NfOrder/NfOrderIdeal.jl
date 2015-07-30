################################################################################
#
#  NfOrder_ideals: Ideals in orders of number fields
#
################################################################################

export NfOrderIdeal

export ideal, colon_ideal, basis_mat_inv

NfOrderIdealSetID = ObjectIdDict()

type NfOrderIdealSet
  order::NfOrder
  
  function NfOrderIdealSet(a::NfOrder)
    try
      return NfOrderIdealSetID[a]
    catch
      NfOrderIdealSetID[a] = new(a)
      return NfOrderIdealSetID[a]
    end
  end
end

type NfOrderIdeal <: GenNfOrdIdl
  basis::Array{NfOrderElem, 1}
  basis_mat::fmpz_mat
  basis_mat_inv::FakeFmpqMat
  parent::NfOrderIdealSet

  function NfOrderIdeal(O::NfOrder, a::fmpz)
    z = new()
    z.parent = NfOrderIdealSet(O)
    z.basis_mat = MatrixSpace(ZZ, degree(O), degree(O))(a)
    return z
  end

  function NfOrderIdeal(O::NfOrder, a::fmpz_mat)
    z = new()
    z.parent = NfOrderIdealSet(O)
    z.basis_mat = a
    return z
  end
end

ideal(O::NfOrder, a::fmpz)  = NfOrderIdeal(O,a)

ideal(O::NfOrder, a::Integer) = NfOrderIdeal(O,ZZ(a))

ideal(O::NfOrder, a::fmpz_mat) = NfOrderIdeal(O,a)

order(a::NfOrderIdealSet) = a.order
  
order(a::NfOrderIdeal) = order(parent(a))

parent(a::NfOrderIdeal) = a.parent

function show(io::IO, a::NfOrderIdeal)
  print(io, "Ideal of (")
  print(io, order(a), ")\n")
  print(io, "with basis matrix\n")
  print(io, basis_mat(a))
end

function basis_mat(a::NfOrderIdeal)
  return a.basis_mat
end

function basis(a::NfOrderIdeal)
  O = order(a)
  if isdefined(a, :basis)
    return a.basis
  end
  B = Array(NfOrderElem, degree(order(a)))
  for i in 1:degree(O)
    t = O()
    t.elem_in_nf = zero(nf(O))
    v = Array(fmpz,degree(O))
    for j in 1:degree(O)
      t += basis(O)[j]*basis_mat(a)[i,j]
      #v[j] = basis_mat(a)[i,j]
    end
    B[i] = t
    #B[i].elem_in_basis = v
  end
  a.basis = B
  return a.basis
end

function basis_mat_inv(a::NfOrderIdeal)
  if isdefined(a, :basis_mat_inv)
    return a.basis_mat_inv
  else
    m,d = pseudo_inverse(a.basis_mat)
    a.basis_mat_inv = FakeFmpqMat(m,d)
    return a.basis_mat_inv
  end
end
