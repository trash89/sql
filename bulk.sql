declare
  type id_pro_buy_t is table of inc_so_po_line_item_esh.id_pro_buy%type index by binary_integer;
  type rowid_t is table of rowid index by binary_integer;
  e_ids id_pro_buy_t;
  e_rowids rowid_t;
  cursor c1 is select b.id_pro_buy,a.rowid from inc_ft_purchase_order_esh a,inc_so_po_line_item_esh b where a.id_pro_buy is null and a.id_epo=b.id_epo and a.id_ple=b.id_ple;
begin
    open c1;
    loop
      fetch c1 bulk collect into e_ids,e_rowids limit 300000;
      exit when e_ids.count=0;
      lock table inc_ft_purchase_order_esh in exclusive mode nowait;
      forall i in indices of e_rowids 
        update inc_ft_purchase_order_esh set id_pro_buy=e_ids(i) where rowid=e_rowids(i);
      commit;
    end loop;
    close c1;
end;
/
