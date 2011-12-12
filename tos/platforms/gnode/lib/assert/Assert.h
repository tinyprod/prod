#ifndef ASSERT_H
#define ASSERT_H

// define the unique() key for generating unique assertion identifiers
#define UQ_ASSERT "Assert"

enum PredefinedAssertions {
	ASSERT_UNUSED = unique(UQ_ASSERT),
	ASSERT_RESERVED1 = unique(UQ_ASSERT),
	ASSERT_RESERVED2 = unique(UQ_ASSERT),
	ASSERT_RESERVED3 = unique(UQ_ASSERT),
	ASSERT_CANT_HAPPEN = unique(UQ_ASSERT),
};

#endif
