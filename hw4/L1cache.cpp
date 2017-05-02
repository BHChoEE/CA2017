#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include "L1cache.h"
#include "Mem.h"
#include <math.h>
using namespace std;

L1cache::L1cache (Mem* memory,int way = 1) {
	L1readhit = 0;
	L1readmiss = 0;
	L1writehit = 0;
	L1writemiss = 0;
	mem = memory;
	way_number = way;
	for(int i=0; i < L1size; i++) {
		for (int j=0; j < 4; j++) {
			cache[i][j] = 0;
		}
	}
}

int L1cache::getfromCache(const int address){

	//==================================================
	//===			TODO		 					 ===
	//==================================================
	
	//initialization
	int m = log2(L1size / way_number);
	int tag = address >> (m+2);
	size_t leastRecent = (address >> 2) % (1 << m);
	size_t location = 0;
	bool found = false;
	//check if exist address in cache
	for(int i = 0 ; i < way_number ; ++i){
		size_t checkBlock = (L1size / way_number) * i + (address >> 2 ) % (1 << m);
		//for Least Recent
		cache[checkBlock][2] -- ;
		if(cache[leastRecent][2] > cache[checkBlock][2])
			leastRecent = checkBlock;
		//to check if address exist
		if(cache[checkBlock][3] == tag && cache[checkBlock][0] == 1){
			found = true;
			location = checkBlock;
		}
	}
	//if address exists , TODO: get the memory from cache
	if(found){
		//for Least recent
		L1readhit ++;
		cache[location][2] = INT_MAX;
		//return memory stored in cache
		return cache[location][4 + address % 4];
	}
	//if not exsists, TODO: push the LR into memory and write with recent one
	else{
		//push LR into memory
		int replaceAddr = (cache[leastRecent][3] << m) + (leastRecent % (1 << m));
		L1readmiss ++;
		if(cache[leastRecent][0] == 1)
			mem -> writetoMem(replaceAddr, cache[leastRecent] + 4);
		//write recent memory into cache
		int* memPtr = mem -> getfromMem(address >> 2);
		for(int i = 0 ; i < 4 ; ++i)
			cache[leastRecent][i+4] = memPtr[i];
		cache[leastRecent][0] = 1;
		cache[leastRecent][2] = INT_MAX;
		cache[leastRecent][3] = tag;
		return cache[leastRecent][address % 4 + 4];
	}
}

void L1cache::writetoCache(const int address,const int indata){
	//==================================================
    //===                   TODO                     ===
    //==================================================
	
	//initialization
	int m = log2(L1size / way_number);
	int tag = address >> (m+2);
	size_t leastRecent = (address >> 2) % (1 << m);
	size_t location = 0;
	bool found = false;
	//check if exist address in cache
	for(int i = 0 ; i < way_number ; ++i){
		size_t checkBlock = (L1size / way_number) * i + (address >> 2 ) % (1 << m);
		//for Least Recent
		cache[checkBlock][2] -- ;
		if(cache[leastRecent][2] > cache[checkBlock][2])
			leastRecent = checkBlock;
		//to check if address exist
		if(cache[checkBlock][3] == tag && cache[checkBlock][0] == 1){
			found = true;
			location = checkBlock;
		}
	}
	//if address exists , TODO: get the memory from cache
	if(found){
		//for Least recent
		L1writehit ++;
		cache[location][2] = INT_MAX;
		//write data in address
		cache[location][4 + address % 4] = indata;
	}
	//if not exsists, TODO: push the LR into memory and write with recent one
	else{
		//push LR into memory
		int replaceAddr = (cache[leastRecent][3] << m) + (leastRecent % (1 << m));
		L1writemiss ++;
		if(cache[leastRecent][0] == 1)
			mem -> writetoMem(replaceAddr, cache[leastRecent] + 4);
		//write recent memory into cache
		int* memPtr = mem -> getfromMem(address >> 2);
		for(int i = 0 ; i < 4 ; ++i)
			cache[leastRecent][i+4] = memPtr[i];
		cache[leastRecent][0] = 1;
		cache[leastRecent][2] = INT_MAX;
		cache[leastRecent][3] = tag;
		cache[leastRecent][address % 4 + 4] = indata;
	}
}

int L1cache::getReadHit(void){
	int temp = L1readhit;
	return temp;
}
int L1cache::getReadMiss(void){
	int temp = L1readmiss;
	return temp;
}
int L1cache::getWriteHit(void){
	int temp = L1writehit;
	return temp;
}
int L1cache::getWriteMiss(void){
	int temp = L1writemiss;
	return temp;
}
int L1cache::getHit(void){
	int temp = L1readhit + L1writehit;
	return temp;
}
int L1cache::getMiss(void){
	int temp = L1readmiss + L1writemiss;
	return temp;
}
