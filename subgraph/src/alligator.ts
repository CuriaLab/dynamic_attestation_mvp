import { Address, BigInt, Bytes } from "@graphprotocol/graph-ts";
import {
  SubDelegation as SubdelegationEvent,
  SubDelegations as SubDelegationsEvent,
  SubDelegations1 as SubDelegations2Event,
} from "../generated/AlligatorOPV5/AlligatorOPV5";
import { SubDelegationRuleObject, recordSubDelegation } from "./helper";
import { SubDelegationEntity } from "../generated/schema";

export function handleSubDelegation(event: SubdelegationEvent): void {
  const fromAddress = event.params.from;
  const toAddress = event.params.to;
  const rule = new SubDelegationRuleObject();
  rule.maxRedelegations = event.params.subdelegationRules.maxRedelegations;
  rule.blocksBeforeVoteCloses =
    event.params.subdelegationRules.blocksBeforeVoteCloses;
  rule.notValidBefore = event.params.subdelegationRules.notValidBefore;
  rule.notValidAfter = event.params.subdelegationRules.notValidAfter;
  rule.customRule = event.params.subdelegationRules.customRule;
  rule.allowanceType = event.params.subdelegationRules.allowanceType;
  rule.allowance = event.params.subdelegationRules.allowance;
  recordSubDelegation(
    fromAddress,
    toAddress,
    rule,
    event.address,
    event.block.number,
    event.block.timestamp,
    event.transaction.hash
  );
}

export function handleSubDelegations(event: SubDelegationsEvent): void {
  const fromAddress = event.params.from;
  const rule = new SubDelegationRuleObject();
  rule.maxRedelegations = event.params.subdelegationRules.maxRedelegations;
  rule.blocksBeforeVoteCloses =
    event.params.subdelegationRules.blocksBeforeVoteCloses;
  rule.notValidBefore = event.params.subdelegationRules.notValidBefore;
  rule.notValidAfter = event.params.subdelegationRules.notValidAfter;
  rule.customRule = event.params.subdelegationRules.customRule;
  rule.allowanceType = event.params.subdelegationRules.allowanceType;
  rule.allowance = event.params.subdelegationRules.allowance;
  for (let i = 0; i < event.params.to.length; i++) {
    const toAddress = event.params.to[i];
    recordSubDelegation(
      fromAddress,
      toAddress,
      rule,
      event.address,
      event.block.number,
      event.block.timestamp,
      event.transaction.hash
    );
  }
}

export function handleSubDelegations2(event: SubDelegations2Event): void {
  const fromAddress = event.params.from;
  for (let i = 0; i < event.params.to.length; i++) {
    const toAddress = event.params.to[i];
    const rule = new SubDelegationRuleObject();
    rule.maxRedelegations = event.params.subdelegationRules[i].maxRedelegations;
    rule.blocksBeforeVoteCloses =
      event.params.subdelegationRules[i].blocksBeforeVoteCloses;
    rule.notValidBefore = event.params.subdelegationRules[i].notValidBefore;
    rule.notValidAfter = event.params.subdelegationRules[i].notValidAfter;
    rule.customRule = event.params.subdelegationRules[i].customRule;
    rule.allowanceType = event.params.subdelegationRules[i].allowanceType;
    rule.allowance = event.params.subdelegationRules[i].allowance;
    recordSubDelegation(
      fromAddress,
      toAddress,
      rule,
      event.address,
      event.block.number,
      event.block.timestamp,
      event.transaction.hash
    );
  }
}
