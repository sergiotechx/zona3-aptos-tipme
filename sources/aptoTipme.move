module account::aptoTipme {
   

   use std::string::{String};
   use std::vector::{empty,push_back}; 
   use std::signer::Self;
   use aptos_framework::aptos_account;
   use aptos_framework::aptos_coin;
   use aptos_framework::coin;
 
   const NotFunds:u64 = 1;
   const ResourceNOtFound:u64  = 2;

   //Typing index
   struct TipIndex has drop,key {
          index : u256,
   }
   //tip definition structure
   struct Tip has drop, key, copy,store{
        articleTittle: String,
        rating: u8,
        observation: String,
   }
  
  //tip definition with index
   struct Mytip has drop,key, copy, store{
     tipIndex: u256,
     tip:Tip,
   }
  //tips vector
  struct Mytips has drop,key, copy, store{
    myTips : vector<Mytip>,
  }
 


 //assign the person who publish their own tips  
 public entry fun assign(myAddress: &signer ){
  let myOwnIndex =  TipIndex{index:0};
  let myOwnTips = Mytips{myTips:empty<Mytip>()};
  move_to(myAddress,myOwnIndex);
  move_to(myAddress,myOwnTips)
 }
 // create a new tip an make a 1000 octa donation
 public entry fun newTip(donatorAddress: &signer,
                         ownerAddress:address,
                         articleTittle: String,
                         rating:u8,
                         observation:String

                        ) acquires Mytips,TipIndex{
      assert!(exists<Mytips>(ownerAddress),ResourceNOtFound);

      let src_addr = signer::address_of(donatorAddress);
      let balance = coin::balance<aptos_coin::AptosCoin>(src_addr);
      
      if(balance - 1000 >0){
       //make 1000 octa donation
        aptos_account::transfer(donatorAddress, ownerAddress, 10000);
       //add article review
        let currentIndex = borrow_global_mut<TipIndex>(ownerAddress);
        let  newIndex =   &mut currentIndex.index;
        *newIndex =  *newIndex +1; 
        let ownerTips = borrow_global_mut<Mytips>(ownerAddress); 
        let newtip =   Tip{ articleTittle,rating,observation};
        let  newMyTip = Mytip{tipIndex:*newIndex,tip:newtip};
        push_back(&mut ownerTips.myTips, newMyTip); 
      }
      else{
        abort NotFunds
      }
      
 }

 #[view]
 public fun getAllTips(myAddress:address):vector<Mytip>  acquires Mytips{
  let ownerTips = borrow_global<Mytips>(myAddress);
  ownerTips.myTips
 }


 
 public entry fun deleteTips(myAddress: &signer) acquires  TipIndex,Mytips{
   let myOwnTipIndex = move_from<TipIndex>(signer::address_of(myAddress));
   let myOwnTips = move_from<Mytips>(signer::address_of(myAddress));
   let TipIndex{index : _} = myOwnTipIndex;
   let Mytips{myTips :_} =myOwnTips;
 }
 
}